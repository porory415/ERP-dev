sap.ui.define([
'benit/ui5/UIComponent'
], function(UIComponent) {
	'use strict';
	var Component = UIComponent.extend('swx.app.zswx2720.Component', {
		metadata : {
			manifest: 'json'
		},
        
        init: function () {
            // call the init function of the parent
            UIComponent.prototype.init.apply(this, arguments);
            // create the views based on the url/hash.
            this.getRouter().initialize();
        },

		receiveMessage : function (data) {
			var oModel = this.getApplicationDataModel()
			oModel.setProperty('/view/headerExpanded', true);
			oModel.setProperty('/view/filter/Data/kunag', [{ code : data, name : data }]);
			this.search({});
		}
	});

	return Component;
});
