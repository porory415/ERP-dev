sap.ui.define([
'sap/ui/core/ComponentContainer'
], function (ComponentContainer) {
	'use strict';

	var oFormatSettings = sap.ui.getCore().getConfiguration().getFormatSettings();
	// oFormatSettings.addCustomCurrencies({
	//    'USD': { // overwrite of an existing CLDR currency
	// 	   'digits': 5
	//    }
	// });
	oFormatSettings.addCustomUnits({
		'KG'   : { 'unitPattern-count-other': '{0}', 'decimals': 1 },
		'TO'   : { 'unitPattern-count-other': '{0}', 'decimals': 3 },
		'M'    : { 'unitPattern-count-other': '{0}', 'decimals': 2 },
		'EA'   : { 'unitPattern-count-other': '{0}', 'decimals': 0 },
		'ZEA'  : { 'unitPattern-count-other': '{0}', 'decimals': 0 },
		'null' : { 'unitPattern-count-other': '{0}', 'decimals': 0 },
		
		'USD'  : { 'unitPattern-count-other': '{0}', 'decimals': 2 },
		'KRW'  : { 'unitPattern-count-other': '{0}', 'decimals': 0 },
		'JPY'  : { 'unitPattern-count-other': '{0}', 'decimals': 0 },
		'EUR'  : { 'unitPattern-count-other': '{0}', 'decimals': 2 },
		'GBP'  : { 'unitPattern-count-other': '{0}', 'decimals': 2 },
		'CNY'  : { 'unitPattern-count-other': '{0}', 'decimals': 2 },
	});


	new ComponentContainer({
		name: 'swx.app.zswx2720',
		height : '100%',
		async: true
	}).placeAt('content');
});