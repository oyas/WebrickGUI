WebrickGUI
----------

Simple Web GUI Interface for All Programs.

Your program output JSON data using standard I/O,
WebrickGUI render HTML automatically.


## Usage

### 1. Use your program I/O

Run the following command.

	$ WebrickGUI.rb ./yourProgram

Then, result on your web browser.
(default address is `localhost:10080`.)

See test1.rb, test2.rb, test3.rb, test4.rb in example.

### 2. Use WebrickGUI I/O

Run the following command.

	$ ./yourProgram

WebrickGUI is expected from your program.

See test5.rb in example.

### 3. Render static page

Use '-c' option.

	$ WebrickGUI.rb -c '{"content":"static page."}'

Render 'index.html.erb' with data of '-c' option's value and shutdown immediately.


## JSON format

example:

	{
		"content": {
			"render": "blocks",
			"content": [
				{
					"render": "html",
					"element": "h2",
					"attribute": {
						"id": "title"
					},
					"content": "TITLE"
				},
				{
					"render": "raw",
					"content": "<p>Hello.</p>",
				}
			]
		}
	}

result:

	<div>
		<div>
			<h2 id="title">TITLE</h2>
		</div>
		<div>
			<p>Hello.</p>
		</div>
	</div>


### render

set renderer type.

#### render type "raw"

If "content" is String, print original value.
(But, it is parsed as HTML.)

#### render type "html"

generate HTML tag.
If you set this render type, you can set "element" and "attribute" option.
"element" is string, 'h1', 'p' or etc...
"attribute" is hash object.

And, this render type has simple style.
You can use "element":{attributes} style.

example:

	{
		"h1": {"id": "title"}
		"content": "TITLE"
	}

#### render type "blocks"

generate div blocks.
"content" is expected Array.


### content

inner contents.
This is JSON data recursively.


