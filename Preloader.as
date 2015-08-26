package  {
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.ProgressEvent;
   import flash.utils.getDefinitionByName;
   import flash.display.Sprite;
   
   public class Preloader extends Sprite
   {
      
      public function Preloader() 
      {
         addEventListener(Event.ENTER_FRAME, progress);
         // show loader
      }
      
      private function progress(e:Event):void 
      {
         // update loader
         if (stage.loaderInfo.bytesLoaded == stage.loaderInfo.bytesTotal)
         {
            removeEventListener(Event.ENTER_FRAME, progress);
            startup();
         }
		 this.graphics.beginFill(0, 1);
		 this.graphics.drawRect(100, 250, 600, 100);
		 this.graphics.endFill();
		 this.graphics.beginFill(0xffffff, 1);
		 this.graphics.drawRect(105, 255, 590 * stage.loaderInfo.bytesLoaded/stage.loaderInfo.bytesTotal, 90);
		this.graphics.endFill();
	}
      
      private function startup():void 
      {
         // instanciate Main class
         var mainClass:Class = getDefinitionByName("net.natpat.Main") as Class;
         addChild(new mainClass() as DisplayObject);
      }
      
   }
   
}