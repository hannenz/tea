public static void docklet_init(Plank.DockletManager manager) {
	manager.register_docklet(typeof(Tea.TeaDocklet));
}

namespace Tea {

	public const string G_RESOURCE_PATH = "/de/hannenz/tea";

	public class TeaDocklet : Object, Plank.Docklet {

		public unowned string get_id() {
			return "tea";
		}

		public unowned string get_name() {
			return "Tea";
		}

		public unowned string get_description() {
			return "A tea timer";
		}

		public unowned string get_icon() {
			return "resource://de/hannenz/tea/icons/tea.png";
		}

		public bool is_supported() {
			return false;
		}

		public Plank.DockElement make_element(string launcher, GLib.File file) {
			return new TeaDockItem.with_dockitem_file(file);
		}
	}
}

