using Plank;
using Gdk;
using Notify;
using Gtk;

namespace Tea {

	public class TeaDockItem : DockletItem {

		public int seconds;
		public Timer timer;

		protected Gee.ArrayList<int?> timers;
		protected int current_item = 0;
		protected int max_items = 3;

		private Gdk.Pixbuf icon_pixbuf;

		public TeaDockItem.with_dockitem_file(GLib.File file) {
			GLib.Object(Prefs: new TeaPreferences.with_file(file));
		}

		construct {
			Logger.initialize("tea");
			Logger.DisplayLevel = LogLevel.NOTIFY;
			
			Notify.init("Tea");

			unowned TeaPreferences prefs = (TeaPreferences) Prefs;

			Icon = "resource://de/hannenz/tea/icons/tea.png";
			Text = "Tea Timer";
			CountVisible = false;
			Count = prefs.minutes;
			ProgressVisible = false;
			Progress = 0;

			seconds = prefs.minutes * 60;
			
			timer = new Tea.Timer(7 * 60);
			timer.finished.connect( () => {
				Logger.notification("*** TEA TIME! ***");
				this.State = Plank.ItemState.URGENT;
				try {
					var notification = new Notify.Notification ("Tea Time!", "Enjoy", "dialog-information");
					notification.set_urgency(Urgency.NORMAL);
					notification.set_image_from_pixbuf(
						new Pixbuf.from_resource("/de/hannenz/tea/icons/tea.png")
					);
					notification.show ();
				} catch (Error e) {
					error ("Error: %s", e.message);
				}
			});
			timer.update.connect( (progress) => {
				Progress = progress;
				Text = "Tea Time in %s".printf(timer.get_remaining());
				reset_icon_buffer();
			});
			timers = new Gee.ArrayList<int?>();
			try {
				icon_pixbuf = new Gdk.Pixbuf.from_resource("/de/hannenz/tea/icons/tea.png");
			}
			catch (Error e) {
				warning("Error: " + e.message);
			}
		}

		public override Gee.ArrayList<Gtk.MenuItem> get_menu_items() {
			var items = new Gee.ArrayList<Gtk.MenuItem>();
			
			for (var i = timers.size; i > 0; i--) {
				var sec = timers.get(i - 1);
				var label = "%u:%02u".printf(sec / 60, sec % 60);
				var item = create_menu_item(label, "", true);
				var pos = i;
				item.activate.connect( () => {
					timer.stop();
					timer.seconds = timers.get(pos - 1);
					Logger.notification("Loaded timer with: %u".printf(timer.seconds));
					reset_icon_buffer();
				});
				items.add(item);
			}

			var item = create_menu_item("Add timer", "", true);
			item.activate.connect(add_timer);
			items.add(item);

			item = create_menu_item("Clear all timers", "", true);
			item.activate.connect(clear_timers);
			items.add(item);

			return items;
		}

		protected override void draw_icon(Plank.Surface surface) {
			Cairo.Context ctx = surface.Context;

			Gdk.Pixbuf pb = icon_pixbuf.scale_simple(surface.Width, surface.Height, Gdk.InterpType.BILINEAR);
			Gdk.cairo_set_source_pixbuf(ctx, pb, 0, 0);
			ctx.paint();

			ctx.set_source_rgb(0.3, 0.3, 0.3);
			ctx.select_font_face("Adventure", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
			ctx.set_font_size(12);
			ctx.move_to(10, 30);
			ctx.show_text(timer.get_remaining());
		}

		private void clear_timers() {
		}

		private void add_timer() {
			var dlg = new TimerWindow();
			dlg.show();
			var response = dlg.run();
			if (response == ResponseType.APPLY) {
				Logger.notification("New timer with %u".printf(dlg.seconds));
				timers.add(dlg.seconds);
			}

			while (timers.size > max_items) {
				timers.remove_at(0);
			}
			
			dlg.destroy();
		}



		protected override AnimationType on_scrolled(Gdk.ScrollDirection dir, Gdk.ModifierType mod, uint32 event_time) {

			switch (dir) {
				case Gdk.ScrollDirection.UP:
					timer.seconds += 60;
					break;

				case Gdk.ScrollDirection.DOWN:
					if (timer.seconds > 60) {
						timer.seconds -= 60;
					}
					break;
			}
			reset_icon_buffer();
			timer.stop();
			
			return AnimationType.NONE;
		}

		protected override AnimationType on_clicked(PopupButton button, Gdk.ModifierType mod, uint32 event_time) {

			if (button == PopupButton.LEFT) {
				
				if (!timer.is_running()) {
					ProgressVisible = true;
					Progress = 0;

					timer.start();
				}
				else {
					timer.stop();
					ProgressVisible = false;
				}
				return AnimationType.BOUNCE;
			}
			return AnimationType.NONE;
		}
	}
}
