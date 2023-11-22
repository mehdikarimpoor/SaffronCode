package nativeClasses.inappPurches.bazar
{
	import flash.events.Event;
	import flash.utils.getDefinitionByName;

	public class BazarInApp
	{
		/**com.pozirk.payment.android.InAppPurchase*/
		private static var 	_iap:*,
							InAppPurchaseClass:Class;
		
		/**com.pozirk.payment.android.InAppPurchaseDetails*/
		private static var InAppPurchaseDetailsClass:Class;
		
		/**com.pozirk.payment.android.InAppPurchaseEvent*/
		private static var InAppPurchaseEventClass:Class ;
		
		private static var onDone:Function,
							onCanseled:Function;
							
		private static var bazarInit:Boolean = false ;
		
		private static var CurrentProdId:String ;
		
		private static var isSatUpOnce:Boolean = false ;
		
		/**
					//trace (_purchase._orderId);
					//trace (_purchase._packageName);
					//trace (_purchase._payload);
					//trace (_purchase._purchaseState);
					//trace (_purchase._signature);
					//trace (_purchase._sku);
					//trace (_purchase._time);
					//trace (_purchase._token);
					//trace (_purchase._type);*/
		private static var lastShopedItemDetail:Object ;
		private static var ConsumeIt:Boolean;
		
		/**Returns true if the code is satup*/
		public static function isSupport():Boolean
		{
			setUp();
			return isSatUpOnce ;
		}
		
		/***/
		private static function setUp():void
		{
			if(isSatUpOnce)
			{
				return ;
			}
			try
			{
				InAppPurchaseClass = getDefinitionByName("com.pozirk.payment.android.InAppPurchase") as Class ;
				InAppPurchaseDetailsClass = getDefinitionByName("com.pozirk.payment.android.InAppPurchaseDetails") as Class ;
				InAppPurchaseEventClass = getDefinitionByName("com.pozirk.payment.android.InAppPurchaseEvent") as Class;
				if(InAppPurchaseClass!=null && InAppPurchaseDetailsClass!=null && InAppPurchaseEventClass!=null)
				{
					isSatUpOnce = true ;
				}
			}
			catch(e)
			{
				isSatUpOnce = false ;
			}
		}
		
		private static function canselAllListeners():void
		{
			if(_iap==null)
			{
				return ;
			}
			_iap.removeEventListener(InAppPurchaseEventClass.INIT_SUCCESS, onInitSuccess);
			_iap.removeEventListener(InAppPurchaseEventClass.INIT_ERROR, onInitError);
			
			_iap.removeEventListener(InAppPurchaseEventClass.PURCHASE_SUCCESS, onPurchaseSuccess);
			_iap.removeEventListener(InAppPurchaseEventClass.PURCHASE_ALREADY_OWNED, onPurchaseSuccess);
			_iap.removeEventListener(InAppPurchaseEventClass.PURCHASE_ERROR, onPurchaseError);
			
			_iap.removeEventListener(InAppPurchaseEventClass.RESTORE_SUCCESS, onRestoreConsumeSuccess);
			_iap.removeEventListener(InAppPurchaseEventClass.RESTORE_ERROR, onRestoreConsumeError);
			
			_iap.removeEventListener(InAppPurchaseEventClass.CONSUME_SUCCESS, onConsumeSuccess);
			_iap.removeEventListener(InAppPurchaseEventClass.CONSUME_ERROR, onConsumeError);
		}
		
		public static function buy(key:String,productId:String,numberOfShop:uint,onBought:Function,onFaild:Function,consumeIt:Boolean=true):void
		{
			ConsumeIt = consumeIt ;
			if(!isSupport())
			{
				throw "Controll the isSupport() function first."
			}
			SaffronLogger.log("[[[[[[[[[CAFE BAZAR]]]]]]]]]]");
			if(_iap==null)
			{
				_iap = new InAppPurchaseClass(); 
			}
			
			CurrentProdId = productId ;
			
			onDone = onBought ;
			onCanseled = onFaild ;
			
			canselAllListeners();
			if(!bazarInit)
			{
				SaffronLogger.log("***connect to bazar...");
				_iap.addEventListener(InAppPurchaseEventClass.INIT_SUCCESS, onInitSuccess);
				_iap.addEventListener(InAppPurchaseEventClass.INIT_ERROR, onInitError);
				_iap.init(key);
			}
			else
			{
				SaffronLogger.log( "InAppBilling supported" );
				purchessItem();
			}
		}
		
		protected static  function onInitSuccess(event:*):void
		{
			bazarInit = true ;
			SaffronLogger.log( "InAppBilling supported2" );
			canselAllListeners();
			
			purchessItem();
		}
		
			/**Now purchess my item*/
			private static function purchessItem():void
			{
				SaffronLogger.log("****Buy this item : "+CurrentProdId);
				canselAllListeners();
				_iap.addEventListener(InAppPurchaseEventClass.PURCHASE_SUCCESS, onPurchaseSuccess);
				_iap.addEventListener(InAppPurchaseEventClass.PURCHASE_ALREADY_OWNED, onPurchaseSuccess);
				_iap.addEventListener(InAppPurchaseEventClass.PURCHASE_ERROR, onPurchaseError);
				_iap.purchase(CurrentProdId, (InAppPurchaseDetailsClass as Object).TYPE_INAPP);
			}
			
				protected static function onPurchaseError(event:Event):void
				{
					canselAllListeners();
					SaffronLogger.log("-----Purchase fails");
					onCanseled();
				}
				
				/**Puchase done*/
				protected static function onPurchaseSuccess(event:*):void
				{
					canselAllListeners();
					SaffronLogger.log("-----Purchase done: ["+event.data+"] ... consume it");
					//onDone();
					consumeProduct(CurrentProdId,onDone,onCanseled);
				}
			
		protected static function onInitError(event:*):void
		{
			canselAllListeners();
			SaffronLogger.log( "!!!!!!!!InAppBilling not supported" );
			SaffronLogger.log(event.data); //trace error message
			onCanseled();
		}
		
//////////////////////////////////////////////////Consume or use the last bought product
		
		public static function consumeProduct(producID:String,onConsumed:Function,onFaildToConsume:Function):void
		{
			onDone = onConsumed ;
			onCanseled = onFaildToConsume;
			CurrentProdId = producID ;
			
			SaffronLogger.log("*** Restore server to consume")
			canselAllListeners();
			_iap.addEventListener(InAppPurchaseEventClass.RESTORE_SUCCESS, onRestoreConsumeSuccess);
			_iap.addEventListener(InAppPurchaseEventClass.RESTORE_ERROR, onRestoreConsumeError);
			_iap.restore();
		}
		
			protected static function onRestoreConsumeError(event:*):void
			{
				canselAllListeners();
				SaffronLogger.log( "restoreConsome Failed" );
				onCanseled();
			}
		
			protected static function onRestoreConsumeSuccess(event:*)
			{
				SaffronLogger.log("**** request to consume product : "+CurrentProdId);
				
				lastShopedItemDetail = _iap.getPurchaseDetails(CurrentProdId);
				if(lastShopedItemDetail != null ){
					trace (lastShopedItemDetail._json);
					//trace (_purchase._orderId);
					//trace (_purchase._packageName);
					//trace (_purchase._payload);
					//trace (_purchase._purchaseState);
					//trace (_purchase._signature);
					//trace (_purchase._sku);
					//trace (_purchase._time);
					//trace (_purchase._token);
					//trace (_purchase._type);
				}  
				
				canselAllListeners();
				
				if(!ConsumeIt)
				{
					var purchaseTocken:String = "NonConsumableItem";
					if(lastShopedItemDetail!=null)
					{
						purchaseTocken = lastShopedItemDetail._token ;
					}
					onDone(purchaseTocken);
				}
				else
				{
					_iap.addEventListener(InAppPurchaseEventClass.CONSUME_SUCCESS, onConsumeSuccess);
					_iap.addEventListener(InAppPurchaseEventClass.CONSUME_ERROR, onConsumeError);
					_iap.consume(CurrentProdId);
				}
			}
			
				protected static function onConsumeSuccess(event:*):void
				{
					canselAllListeners();
					SaffronLogger.log("Consume Success"); 
					var purchaseTocken:String ;
					if(lastShopedItemDetail!=null)
					{
						purchaseTocken = lastShopedItemDetail._token ;
					}
					if(onDone.length>0)
					{
						onDone(purchaseTocken);
					}
					else
					{
						onDone();
					}
				}
				protected static function onConsumeError(event:*):void
				{
					canselAllListeners();
					SaffronLogger.log("Consume Failed"); 
					onCanseled();
				}
		
	}
}