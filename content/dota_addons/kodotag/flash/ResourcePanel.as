package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class ResourcePanel extends MovieClip
	{
		// element details filled out by game engine
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;
		
		public function ResourcePanel() { }
		
		// called by the game engine when this .swf has finished loading
		public function onLoaded():void
		{
			this.gameAPI.SubscribeToGameEvent("updateResourcePanel", this.updateResourcePanel);
		}
		
		public function updateResourcePanel(eventData:Object):void
		{
			trace("tried blablab eupdate"+this.globals.Players.GetLocalPlayer()==eventData.player_ID);
			if(this.globals.Players.GetLocalPlayer()==eventData.player_ID)
			{
				visible=true;
				food.text=eventData.food+"/"+eventData.foodMax;
				wood.text=eventData.wood;
				gold.text=eventData.gold;
				trace("SUCCESS UPDATE FOODWOOD")
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
	}
}
