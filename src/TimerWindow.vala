using Gtk;

namespace Tea {

	public class TimerWindow : Gtk.Dialog {

		public int seconds { get; set; }

		private Gtk.SpinButton minutes_spin_button;
		private Gtk.SpinButton seconds_spin_button;
		private Gtk.Widget add_timer_button;


		public TimerWindow() {
			title = "Add timer";
			border_width = 5;
			create_widgets();
		}

		private void create_widgets() {
			minutes_spin_button = new SpinButton.with_range(0, 99, 1);
			seconds_spin_button = new SpinButton.with_range(0, 59, 1);

			minutes_spin_button.value_changed.connect(update_seconds);
			seconds_spin_button.value_changed.connect(update_seconds);

			var hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			hbox.pack_start(minutes_spin_button, false, true, 0);
			hbox.pack_start(seconds_spin_button, false, true, 0);

			var content = get_content_area() as Gtk.Box;
			content.pack_start(hbox, false, true, 0);
			content.spacing = 10;

			add_button("_Cancel", ResponseType.CANCEL);
			add_timer_button = add_button("_Add", ResponseType.APPLY);
			add_timer_button.sensitive = false;
			
			show_all();
		}

		private void update_seconds() {
			seconds = (int)minutes_spin_button.value * 60 + (int)seconds_spin_button.value; 
			add_timer_button.sensitive = (seconds > 0);
		}

	}
}
