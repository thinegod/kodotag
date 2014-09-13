package  {
	
	import flash.display.MovieClip;
	
			
	
	public class CustomError extends MovieClip {
		
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;

		
		public function CustomError() {
		}
		
		public function onLoaded() : void {			
			//make this UI visible
			visible = true;
			
			//let the client rescale the UI
			this.gameAPI.SubscribeToGameEvent("error_msg", this.showError);
			
		}
		
		public function showError( args:Object ){
			var pID:int = this.globals.Players.GetLocalPlayer();
			
			if( pID == args.player_ID ) {
				this.globals.Loader_error_msg.movieClip.setErrorMsg(args._error);
			}
		}
		

	}
	
}