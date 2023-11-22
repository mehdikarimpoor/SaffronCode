package contents.alert
{
	import flash.display.Stage;
	import flash.media.StageWebView;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import nativeClasses.vibration.VibrationDistriqt;

	public class Alert
	{
		private static var sw:StageWebView ;
		
		private static var 	debugField1:TextField;

		public function Alert(...val)
		{
			Alert.show(val);
		}
		
		public static function show(...param):void
		{
            var title:String = param.join(',');
			setUp();
			//SaffronLogger.log("Alert:"+title);
			if(debugField1!=null)
			{
				debugField1.appendText(title+'\n');
				
				
				debugField1.scrollV+=1000;
			
			}
			else
			{
				sw.loadURL("javascript:alert(\""+title.split('\n').join('').split('\r').join('').split('\\').join('\\\\').split('"').join('\\"')+"\");")
			}
		}
		
		/**
		 * You need vibration permission:  
		 * uses-permission android:name="android.permission.VIBRATE"
		 * @param duration 
		 */
		public static function vibrate(duration:uint=1000):void
		{
			setUp();
			if(VibrationDistriqt.isSupported())
			{
				SaffronLogger.log("Distriqt vibratin is supported");
				VibrationDistriqt.vibrate(duration);
			}
			else if(DevicePrefrence.isAndroid())
			{
            	sw.loadURL("javascript:navigator.vibrate("+duration+");")
			}
		}
		/**
		 * You need vibration permission:  
		 * uses-permission android:name="android.permission.VIBRATE"
		 * @param duration 
		 */
		public static function vibrateDynamic(patternArray:Array):void
		{
			setUp();
			if(VibrationDistriqt.isSupported())
			{
				SaffronLogger.log("Distriqt vibratin is supported");
				VibrationDistriqt.vibrateDynamic(patternArray);
			}
			if(DevicePrefrence.isAndroid())
			{
            	sw.loadURL("javascript:navigator.vibrate("+JSON.stringify(patternArray)+");")
			}
		}
		
		/**
		 * You need vibration permission:  
		 * uses-permission android:name="android.permission.VIBRATE"
		 * @param duration 
		 */
		public static function vibratePuls():void
		{
			if(VibrationDistriqt.isSupported())
			{
				SaffronLogger.log("Distriqt supported")
				VibrationDistriqt.puls();
			}
			else if(DevicePrefrence.isAndroid())
			{
				SaffronLogger.log("NO! Distriqt")
            	vibrate(30);
			}
		}
		
		/**Create the sw for allerts*/
		private static function setUp():void	
		{
			if(sw==null)
				sw = new StageWebView();
		}

		public static function isSateDebuggerActivated():Boolean
		{
			return debugField1!=null;
		}
		
		/**Set Screen debugger instead on Alert*/
		public static function setScreenDebugger(stage:Stage):void
		{
			debugField1 = new TextField();
			
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.size = 18;
			
			debugField1.width = stage.stageWidth ;
			debugField1.height = stage.stageHeight ;
			
			
			debugField1.textColor = 0xFF0000 ;
			
			
			
			debugField1.defaultTextFormat = textFormat;
			
			
			debugField1.x = 1;
			debugField1.y = 1;
			
			
			debugField1.mouseEnabled = false ;
			
			stage.addChild(debugField1);
		}
	}
}