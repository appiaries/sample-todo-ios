Todo App Demo for Appiaries (iOS)
===========================

## About This App

Users register with their email address, and login with Login ID and Password.  
Or, they can use Twitter/Facebook account to login.  
Users can add/edit/delete todo tasks. Main view shows a weekly tasks list.  
Tapping on the task to manage the detail about the task.  

## Updates

* [2015-06-29] Upgraded the _Appiaries SDK_ vesion from _**"v.2.0.0"**_ to _**"v.2.0.2"**_.
* [2015-06-23] Upgraded the _Appiaries SDK_ vesion from _**"Appiaries SDK v.1.4.0"**_ to _**"Appiaries SDK v.2.0.0"**_.

## Requirements

It does not require you an Appiaries account if you just want to build and run the app.  
Although it requires server-side data stored on Appiaries,  
it is already configured as default to retrieve the ones from our demo account.  
If you intend to customize the server-side data, you need a sign-up.  
Runs on iOS 7.1 or higher.

## License

You may freely use, modify, or distribute the source codes provided.

## Appiaries API Services Used

* <a href="http://docs.appiaries.com/?p=11015&lang=en">JSON Data API</a>
* <a href="http://docs.appiaries.com/?p=11135&lang=en">App User API</a>

## Appearance

<table>

<tr>
<td>
<b>Top</b><br />
<img src="http://docs.appiaries.com/wordpress/wp-content/uploads/img/sample_todo_shot_top.png">
</td>
<td>
<b>Register</b><br />
<img src="http://docs.appiaries.com/wordpress/wp-content/uploads/img/sample_todo_shot_regist.png">
</td>
<td>
<b>Login</b><br />
<img src="http://docs.appiaries.com/wordpress/wp-content/uploads/img/sample_todo_shot_login.png">
</td>
</tr>

<tr>
<td>
<b>SNS Login</b><br />
<img src="http://docs.appiaries.com/wordpress/wp-content/uploads/img/sample_todo_shot_login_facebook.png">
</td>
<td>
<b>SNS Login 2</b><br />
<img src="http://docs.appiaries.com/wordpress/wp-content/uploads/img/sample_todo_shot_login_facebook2.png">
</td>
<td></td>
</tr>

<tr>
<td>
<b>Add</b><br />
<img src="http://docs.appiaries.com/wordpress/wp-content/uploads/img/sample_todo_shot_add2.png">
</td>
<td>
<b>List</b><br />
<img src="http://docs.appiaries.com/wordpress/wp-content/uploads/img/sample_todo_shot_list2.png">
</td>
<td>
<b>Task Done</b><br />
<img src="http://docs.appiaries.com/wordpress/wp-content/uploads/img/sample_todo_shot_list3_done.png">
</td>
</tr>

<tr>
<td>
<b>Edit</b><br />
<img src="http://docs.appiaries.com/wordpress/wp-content/uploads/img/sample_todo_shot_edit.png">
</td>
<td>
<b>Edit Date</b><br />
<img src="http://docs.appiaries.com/wordpress/wp-content/uploads/img/sample_todo_shot_edit_calender.png">
</td>
<td>
<b>Delete</b><br />
<img src="http://docs.appiaries.com/wordpress/wp-content/uploads/img/sample_todo_shot_delete.png">
</td>
</tr>

</table>


## Server-Side Collections Used

<table>

<tr>
<th>Entity</th>
<th>System Name</th>
<th>Type</th>
<th>Description</th>
<th>Note</th>
</tr>

<tr>
<td>App Users</td>
<td>(App User)</td>
<td>No collections to be created but App User feature to be used.</td>
<td>Stores App User information using this TODO App. In each App User data.</td>
<td></td>
</tr>

<tr>
<td>Tasks</td>
<td>Tasks</td>
<td>JSON Collection</td>
<td>Stores all the tasks for everyone.</td>
<td></td>
</tr>

</table>


## Reference

For further details, refer to the official documents on Appiaries.

in English  
http://docs.appiaries.com/?p=14850&lang=en

in Japanese  
http://docs.appiaries.com/?p=14767

Also, iOS version available on GitHub.  
https://github.com/appiaries/sample-todo-android

Appiaries  
http://www.appiaries.com/
