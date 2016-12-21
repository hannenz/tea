namespace Tea {
	
	public enum TimerState {
		STOPPED,
		RUNNING
	}	

	public class Timer  {

		public int seconds { get; set; }
		public Tea.TimerState state { get; set; }
		public int updateInterval { get; set; }

		private GLib.Timer timer;

		public signal void finished();
		public signal void update(double progress);


		public Timer(int seconds) {

			timer = new GLib.Timer();

			this.seconds = seconds;
			state = TimerState.STOPPED;

			updateInterval = 1;
		}


		public void start() {
			
			state = TimerState.RUNNING;
			timer.start();

			Idle.add( () => {
				
				if (timer.elapsed() >= seconds) {
					timer.stop();
					finished();
					return false;
				}
				return true;
			});
			Timeout.add_seconds(updateInterval, () => {
				update(timer.elapsed() / seconds);
				return is_running();
			});
		}


		public void stop() {
			timer.stop();
			timer.reset();
			state = TimerState.STOPPED;
		}


		public bool is_running() {
			return (state == TimerState.RUNNING);
		}

		public double get_progress() {
			return (timer.elapsed() / seconds);
		}

		public string get_remaining() {
			var remaining = seconds - timer.elapsed();

			return "%u:%02u".printf((int)(remaining / 60), (int)(remaining % 60));

		}
	}
}
