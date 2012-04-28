var Rating = Backbone.Model.extend({});

var Ratings = Backbone.Collection.extend({
	model: Rating, 
	url: '../pluginStatus'
});

var StatusItem = Backbone.View.extend({
	initialize: function() {
		_.bindAll(this, 'render');
	},
	render: function() {
		var variables = {
			status: this.model.attributes.status === 0 ? '<span class="badge badge-success">Yup</span>' : '<span class="badge badge-important">Nope</span>',
			issues: this.model.attributes.issues
		};
		var data = this.model.toJSON();
		_.extend(data, variables);
		this.template = _.template($('#status_item_template').html());
		return this.template(data);
	}
});

var StatusTable = Backbone.View.extend({
	el: $("table#status_table"),
	initialize: function() {
		_.bindAll(this, 'addOne', 'addAll');
		this.collection.bind('reset', this.addAll);
		this.collection.fetch();
	}, 
	addOne: function(status) {
		$(this.el).find('tbody').append(new StatusItem({model: status}).render());
	},
	addAll: function() {
		_.each($(this.el).find('tbody tr'), function(tr) {
			$(tr).remove();
		});
		this.collection.each(this.addOne);
	},
	update: function() {
		$.blockUI({ message: '<h3><img src="img/loading.gif" /> Updating status. Just a sec!</h3>' });
		_.each($(this.el).find('tbody tr'), function(tr) {
			$(tr).remove();
		});
		this.collection.fetch({'success': function() {$.unblockUI();}});
	}
});

var pluginStatus = new Ratings();
var statusTable = new StatusTable({collection: pluginStatus});

var FeedbackForm = Backbone.View.extend({
	el: $('#ratings_form'), 
	initialize: function() {
		_.bindAll(this, 'render');
		$('select#status').change(function() {
			if($(this).val() == '1') {
				$('#issue_id').removeAttr('readonly');
			} else {
				$('#issue_id').val('');
				$('#issue_id').attr('readonly', 'readonly');
			}
		});
		$(this.el).submit(function(evt) {
			$.ajax({
			    type: "POST",
			    url: evt.target.action,
			    data:$(evt.target).serialize(),
			    success: function() {
			      statusTable.update();
			      $.unblockUI();
			    }
		  	});
			$.blockUI({ message: '<h3><img src="img/loading.gif" /> Submitting. Just a sec!</h3>' });
			return false;
		});
	}, 
	render: function() {
	}
});

new FeedbackForm().render();

$('button#status_update').click(function() {
	statusTable.update();
});
