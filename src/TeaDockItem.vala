using Plank;
using Gdk;
using Notify;

namespace Tea {

	public class TeaDockItem : DockletItem {

		public int seconds;
		public Timer timer;

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
			CountVisible = true;
			Count = prefs.minutes;
			ProgressVisible = false;
			Progress = 0;

			seconds = prefs.minutes * 60;
		}

		public override Gee.ArrayList<Gtk.MenuItem> get_menu_items() {
			var items = new Gee.ArrayList<Gtk.MenuItem>();
			
			for (var i = 10; i > 0; i--) {
				var item = create_menu_item("%u:00".printf(i), "", true);
				item.activate.connect( () => {
					Count = int.parse(item.label);
					seconds = (int)Count * 60;
				});
				items.add(item);
			}
			return items;
		}


		protected override AnimationType on_scrolled(Gdk.ScrollDirection dir, Gdk.ModifierType mod, uint32 event_time) {

			switch (dir) {
				case Gdk.ScrollDirection.UP:
					Count++;
					break;

				case Gdk.ScrollDirection.DOWN:
					if (Count > 1) {
						Count--;
					}
					break;
			}
			timer.stop();
			
			seconds = (int)Count * 60;

			unowned TeaPreferences prefs = (TeaPreferences) Prefs;
			prefs.minutes = (int)Count;
			return AnimationType.NONE;
		}

		protected override AnimationType on_clicked(PopupButton button, Gdk.ModifierType mod, uint32 event_time) {

			if (button == PopupButton.LEFT) {
				
				if (!timer.is_running()) {
					ProgressVisible = true;
					Progress = 0;

					timer = new Tea.Timer(seconds);
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
					});

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
