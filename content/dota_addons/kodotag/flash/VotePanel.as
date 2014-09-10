package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class VotePanel extends MovieClip
	{
		// element details filled out by game engine
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;
		private var player_ID:int;
		public function VotePanel() { }
		
		// called by the game engine when this .swf has finished loading
		public function onLoaded():void
		{
			this.gameAPI.SubscribeToGameEvent("start_vote", this.startVote);
		}
		
		public function startVote( args:Object )
		{
			this.player_ID=args.player_ID;
			if(this.globals.Players.GetLocalPlayer()==this.player_ID)
			{
				visible=true;
				//textThing.visible=true;
				noob.addEventListener(MouseEvent.CLICK,difficultySelect);
				easy.addEventListener(MouseEvent.CLICK,difficultySelect);
				normal.addEventListener(MouseEvent.CLICK,difficultySelect);
				hard.addEventListener(MouseEvent.CLICK,difficultySelect);
				extreme.addEventListener(MouseEvent.CLICK,difficultySelect);
			}
			
		}
		// called by the game engine after onLoaded and whenever the screen size is changed
		public function onScreenSizeChanged():void
		{
			// By default, your 1024x768 swf is scaled to fit the vertical resolution of the game
			//   and centered in the middle of the screen.
			// You can override the scaling and positioning here if you need to.
			// stage.stageWidth and stage.stageHeight will contain the full screen size.
		}
		
		private function difficultySelect(e:MouseEvent)
		{

			if(this.globals.Players.GetLocalPlayer()==this.player_ID)
			{
				visible=false;
				gameAPI.SendServerCommand("difficultyVote "+e.currentTarget.label);
			}
		}
	}
}
