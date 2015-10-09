# RCAV + CRUD

## Introduction

The goal of this project is to understand how to allow users to generate data for our database tables through their browsers. To do this, you will write one complete database-backed web CRUD resource.

We just need to put together everything we've learned about RCAV with everything we've learned about CRUDing models with Ruby.

Every web application is nothing more than a collection of related resources that users can CRUD, so understanding how each of these operations works on one table is essential. For example, Twitter allows a user to

 - sign up (**create** a row in the users table)
 - edit profile (**update** his or her row in the users table)
 - tweet (**create** a row in the statuses table)
 - delete a tweet (**destroy** that row in the statuses table)
 - I believe Twitter doesn't allow you to edit a tweet, so they don't support a route to trigger an **update** action for a row in the statuses table
 - follow/unfollow other users (**create** / **destroy** a row in the followings table)
 - favorite/unfavorite a tweet (**create** / **destroy** a row in the favorites table)
 - etc.

At the most basic level, for every interaction we want to support, we have make up a URL that will trigger a controller action which performs that interaction.

Then we need to give the users a way to visit that URL (there's only two ways: either a link or a form submit button which point to that URL).

For each web resource, we usually support seven actions (with some exceptions, like Twitter not supporting editing of tweets). **The Golden Seven** actions are:

#### Create
 - new_form: displays a blank form to the user
 - create_row: receives info from the new form and inserts a row into the table

#### Read
 - index: displays a list of multiple rows
 - show: displays the details of one row

#### Update
 - edit_form: displays a pre-populated form to the user with existing data
 - update_row: receives info from the edit form and updates a row in the table

#### Delete
 - destroy: removes a row from the table

Let's get started.

## The Target

To start with, we'll keep it simple and manage just one resource: photos. Our goal is to build an app that lets users submit URLs of photos and add captions for them. Check [this][4] out as an example, but without the user avatars and comments.

Eventually, we'll add the ability to sign up, upload photos, and follow other users, and we'll wind up building Instagram. But for now, anonymous visitors will simply copy-paste the URLs of images that are already on the Internet.

## Setup

 1. Read the instructions completely.
 1. Clone this repository.
 1. `cd` in to the application's root folder.
 1. `bundle install`
 1. `rails server`
 1. Open up the code in Sublime.


### Generate a model

You'll first need to decide what needs to be stored inside the database. You're storing image source and caption information for photos, so you should create a model called `Photo` with columns called `source` and `caption`. `source` should have a data type of string and `caption` should have a data type of text. Run the following terminal command inside your app's folder:

    rails generate model Photo source:string caption:text

This command generates two important files: a model file in the /app/models folder and a migration file in the /db/migrate folder. The model file is the interface that the application code uses to talk to the database. The migration file makes a change to the database - in this case, it adds a new table called photos.

Once you've created a new model, make sure you run the command:

    rake db:migrate

to actually execute the migration you've just created.

### Add items to the database

Inside your app's folder in terminal, open up rails console with

    rails console

This opens up an IRB-like interface where you can run Ruby code. It also an connect to your application code, so it's a great tool for testing small changes to your application.

First check to make sure that the photos table was properly created:

    Photo.all

This should pull up what looks somewhat like an empty array. This object is called an `ActiveRecord` relation, and works like a super-charge array. Since there isn't anything between the `[ ]`, there are no photos in the database.

We can add a photo with the following commands (assuming you followed the naming conventions specified above). Execute each command line-by-line.

    p = Photo.new
    p.source = "http://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/Lake_Bondhus_Norway_2862.jpg/1280px-Lake_Bondhus_Norway_2862.jpg"
    p.caption = "Lake Bondhus"
    p.save

Now if you run `Photo.all` again, you'll see one item in the ActiveRecord relation. Keep adding photos until you have 5-7 photos in your database. If you'd like a more detailed explanation of adding items to the database, check out this [Ruby CRUD Cheatsheet][1].


### READ (show)

You can pull up a specific databse item by it's ID number. For example, if you wanted to pull up an item from the photos table with an ID of 3, you could run the following command in console:

    Photo.find(3)

If you wanted to pull out information from that photo, you could just save the object into a variable and pull out columns using the dot-notation:

    p = Photo.find(3)
    p.source
    p.caption

This is not very user-friendly, though. User should be able to access items through the web interface, not console.

**Your first job** is to display a photo details page for each individual photo. For example, a user should be able to go to "/photos/2" and see information about the photo with an ID of 2 or go to "/photos/3" and see information about the photo with an ID of 3.

I have already added one route to start you off on this challenge:

    get("/photos/:id", { :controller => "photos", :action => "show" })

as well as a controller file and a blank action.

In the `show` action, use the number after the slash to retrieve the row from the `photo` table with the corresponding `id`, and use that row's `source` value to draw the `<img>` in the view. Toss in the `caption`, too.

Hints: Remember your [Ruby CRUD Cheatsheet][1], and what you know about the `params` hash.

### CREATE (new_form, create_row)

We're now done with the "R" in CRUD. Our users can **Read** individual rows and collections of rows from our photos table. But they still have to depend on us to create the data in the first place, through the Rails console or something.

Let's now attack the "C" in CRUD: **Create**. We want to allow users to generate content for our applications; that is almost always where the greatest value lies.

#### new_form

The first step is: let's give the user a form to type some stuff in to. Add the following route:

    get("/photos/new", { :controller => "photos", :action => "new_form" })

This action has a very simple job: draw a blank form in the user's browser for them to type some stuff into.

Craft a form for a photo with two inputs: one for the image's URL and one for a caption. Complete the RCAV and add the following HTML in the view:

    <h1>Add A New photo</h1>

    <form>
      <div>
        <label for="photo_caption">Caption:</label>
        <input id="photo_caption" type="text" name="the_caption">
      </div>
      <div>
        <label for="photo_image_url">Image URL:</label>
        <input id="photo_image_url" type="text" name="the_source">
      </div>
      <div>
        <input type="submit" value="Create photo">
      </div>
    </form>

It turns out that forms, when submitted, take the values that users type in to the inputs and add them to the request. However, they do it by tacking them on to the end of the URL after a `?`, in what is called a **query string**.

"Query string" is HTTP's name for a list of key/value pairs. The **keys** are the `name`s of the `<input>` tags, and the **values** are what the user typed.

In Ruby, we call a list of key/value pairs a Hash. Same thing, different notation. So

    ?sport=football&color=purple

in a URL would translate into something like

    { :sport => "football", :color => "purple" }

in Ruby.

Why do we care? Well, it turns out that Rails does exactly that translation when it sees a query string show up on the end of one of our URLs.

Rails ignores the query string as far as routing is concerned, and still sends the request to same action... but it puts the extra information from the form into the `params` hash for us!

Alright, we're getting close... there's only one problem left. When a user clicks submit on the form, we probably don't want to go right back to the `new_form` action again. That action's job was to draw the blank form on the screen, and we're right back where we started.

We need a way to pick a different URL to send the data to when the user clicks the submit button. If we could do that, then we could set up a route for that URL, and then in the action for that route, we could pluck the information the user typed from the `params` hash and use it to create a new row in our table.

Fortunately, we can very easily pick which URL receives the data from a form: it is determined by adding an `action` attribute to the `<form>` tag, like so:

    <form action="/create_photo">

Think of the action attribute as being like the `href` attribute of the `<a>` tag. It determines where the user is sent after they click. The only difference between a form and a link is that when the user clicks a form, some extra data comes along for the ride, but either way, the user is sent to a new URL.

Of course, because we haven't set up a route to support `"/create_photo"`. Let's do that:

#### create_row

    get("/create_photo", { :controller => "photos", :action => "create_row" })

Add the action and view for that route. Put some static HTML in the view for now.

**Your next job** is to write some Ruby in the `create` action to:

 - create a new row for the photos table
 - fill in its column values by pulling the information the user typed into the form out of the `params` hash
 - save it

Once done, display a confirmation message that the information was saved in the view template.

### DELETE (destroy)

On each photo's show page, create a link to delete the photo. It should look like this:

    <a href="/delete_photo/<%= @photo.id %>">Delete</a>

Does it make sense how that link is being put together?

When I click that link, the photo should be removed and I should be shown a confirmation message.

Write a route, action, and view to make that happen. To start you off, here's a route:

    get("/delete_photo/:id", { :controller => "photos", :action => "destroy" })

### UPDATE (edit_form, update_row)

#### edit_form

In the photo show page, create a link labeled "Edit". The markup for this link looks like:

    <a href="/photos/<%= photo.id %>/edit">Edit</a>

Add a route to support this action:

    get("/photos/:id/edit", { :controller => "photos", :action => "edit_form" })

The job of this action should be to display a form to edit an existing photo, somewhat like the `new_form` action.

It's a little more complicated than `new_form`, though, because instead of showing a blank form, you should show a form that's pre-populated with the current values for a particular photo (determined by what's after the slash).

Hint: You can pre-fill an `<input>` with the `value=""` attribute; e.g.,

    <input type="text" name="the_caption" value="<%= @photo.caption %>">

The `action` attributes of your edit forms should look like this:

    <form action="/update_photo/4">

so that when the user clicks submit, we can finally do the work of updating our database...

#### update_row

Add another route:

    get("/update_photo/:id", { :controller => "photos", :action => "update_row" })

The job of this action is to receive data from an edit form, retrieve the corresponding row from the table, and update it with the revised information. Give it a shot. Afterwards, display a confirmation message in the view.

### READ (index)

#### index

The last action we need to complete is a page that displays every photo in the database. Add this route to get started

    get("/photos", { :controller => "photos", :action => "index" })

The index action should pull up all the photos with `Photo.all` and send them down to the view. The view should loop through each item in the ActiveRecord relation and display the item's image and caption. Use [the original mockup][4] as an example.

## Conclusion

If we can connect all these dots, we will have completed one entire database-backed CRUD web resource. Every web application is essentially just a collection of multiple of these resources; they are the building blocks of everything we do, and we'll just cruise from here.

Struggle with it; **come up with questions**.

#### Optional challenge, for fun:

Connect [Bootstrap][2] or a [Bootswatch][3] and make the index page look similar to [this][4], but without the user avatars and comments.


  [1]: https://gist.github.com/rbetina/bb6336ead63080be2ff4
  [2]: http://www.bootstrapcdn.com/#quickstart_tab
  [3]: http://www.bootstrapcdn.com/#bootswatch_tab
  [4]: http://htmlpreview.github.io/?https://github.com/boothappdev/bootstrap_exercises/blob/master/photogram/solution.html
# photogram
# photogram
