using Plank;

namespace Tea {
	public class TeaPreferences : DockItemPreferences {
		[Description(nick = "minutes", blurb="Minutes")]
		public int minutes;

		public TeaPreferences.with_file(GLib.File file) {
			base.with_file(file);
		}

		protected override void reset_properties() {
			minutes = 7;
		}
	}
}
