<!DOCTYPE html>
<html lang='en'>
<head>
	<meta charset="utf-8">
	<title>Sample plug-in user feedback</title>
	<link href="css/bootstrap.css" rel="stylesheet">
	<style type='text/css'>
		body {
			padding: 15px 0px;
		}
		select.input-medium {
			width: 98%;
		}
		input.input-medium {
			width: 94%;
		}
		.grayish {
			color: #9C9C9C;
		}
	</style>
</head>
<body>
	<div class='container'>
		<div class='row'>
			<div class='span12'>
				<h2 style='text-align: center'>Plug-in compatibility sample</h2>
				<hr />
				<div class="alert alert-info">
				<p><i class='icon-warning-sign'></i>This is only an <em>example application</em>. 
				The feedback form, represents what is very likely to be a page written 
				in jelly in Jenkins UI. However, the jenkins version, plugin name, and other 
				attributes can be retrieved in runtime, without the need of the user to 
				input these values.</p>
				</div>
				<hr />
			</div>
			<hr />
			<div id='submit' class='span4'>
				<h3>Feedback form</h3>
				<form method='post' action='../ratings' id='ratings_form' class='form-vertical well'>
					<label for='jenkins_version'>Jenkins Version</label>
					<select name='jenkins_version' id='jenkins_version' class='input-medium'>
						<option value='1.461'>1.461</option>
						<option value='1.461'>1.460</option>
						<option value='1.461'>1.459</option>
					</select>
					<label for='plugin_name'>Plug-in <span class='grayish'>(junit, maven, cobertura,...)</span></label>
					<input placeholder='' type='text' name='plugin_name' id='plugin_name' value='testlink' class='input-medium' />
					<label for='plugin_version'>Plug-in version</label>
					<select name='plugin_version' id='plugin_version' class='input-medium'>
						<option value='3.0'>3.0</option>
						<option value='3.1'>3.1</option>
						<option value='3.1.1'>3.1.1</option>
					</select>
					<label for='status'>Is it working for you?</label>
					<select name='status' id='status' class='input-medium'>
						<option value='0'>Yes</option>
						<option value='1'>No :-(</option>
					</select>
					<div id='issue_control'>
						<label for='issue_id'>Issue ID <span class='grayish'>(JENKINS-15615 or just 15615)</span></label>
						<input type='text' name='issue_id' id='issue_id' value='' readonly="readonly" class='input-medium' />
					</div>
					<p><button class='btn btn-primary'>Send</button></p>
				</form>
			</div>
			<div class='span3'>
				<h3 style='text-align: center;'>Status update</h3>
				<br />
				<p style='text-align: center;'><button id='status_update' class='btn btn-primary'>Refresh plug-in status</button></p>
			</div>
			<div id='result' class='span5'>
				<h3>Plugin status</h3>
				<table id='status_table' class='table table-striped table-bordered'>
					<thead>
						<th>Jenkins</th>
						<th>Plugin</th>
						<th>Works?</th>
						<th>Issues</th>
					</thead>
					<tbody></tbody>
				</table>
			</div>
		</div>
	</div>
</body>
<script src="js/jquery.js"></script>
<script src="js/jquery.blockUI.js"></script>
<script src="js/underscore.js"></script>
<script src="js/backbone.js"></script>
<script src="js/ratings.js"></script>
<!-- Templates -->
<script type="text/template" id="status_item_template">
<tr>
	<td><%= jenkins_version %></td>
	<td><%= plugin_name %>-<%= plugin_version %></td>
	<td><%= status %></td>
	<td><%= issues %></td>
</tr>
</script>
</html>