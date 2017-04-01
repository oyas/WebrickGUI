WebrickGUI
----------

Simple Web GUI Interface for All Programs.

Your program generate JSON data using standard I/O,
WebrickGUI render HTML automatically.


## Usage

Run the following command.

	$ WebrickGUI.rb ./yourProgram

Then, result on your web browser.
(default address is `localhost:10080`.)


## JSON format

example:

	{
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
(But, it is parsed to HTML.)

#### render type "html"

generate HTML tag.
If you set this render type, you can set "element" and "attribute" option.

#### render type "blocks"

generate div blocks.
"content" is expected Array.


### content

inner contents.


