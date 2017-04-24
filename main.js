/**
 * WebrickGUI main JavaScript.
 */


$(function(){
	// set renderer
	WebrickGUI._renderer = $.extend(true, {}, WebrickGUI.defaultRenderers);

	// set event
	$('#runButton').on('click', WebrickGUI.update);

	// first update
	WebrickGUI.update();
});


var WebrickGUI = {

	// list of renderer
	_renderer: {},

	/**
	 * send JSON data to server, and update
	 */
	send: function(senddata = null){
		$.ajax({
			type: "POST",
			url: "/get",
			data: senddata,
		}).done( (dataAll) => {
			$('#content').empty();
			console.log(dataAll);
			// pre parse
			data = WebrickGUI.preparse(dataAll);
			console.log(data);
			// parse JSON data
			let result = WebrickGUI.parse(data);
			console.log( result instanceof jQuery ? result.html() : result );
			// append parse result
			$('#content').append( result );
		});
	},

	/**
	 * get JSON data from server, and update content
	 */
	update: function(){
		WebrickGUI.send();
	},

	/**
	 * pre parse JSON data
	 */
	preparse: function(data){
		if( !('content' in data) ){
			return null;
		}else{
			return data['content'];
		}
	},

	/**
	 * parse JSON data
	 *
	 * @param data:     parse data
	 *
	 * 1. basic style. render by "render" renderer.
	 *  {
	 *      "render": "renderer name",
	 *      "content": data,
	 *  }
	 *
	 * 2. html renderer short style. render by html renderer.
	 *  {
	 *      "element name": {attributes},
	 *      "content": data,
	 *  }
	 *
	 * 3. Array. render by blocks renderer.
	 *  [ data, ... ]
	 *
	 * 4. other data type. render by raw renderer.
	 *  "string"
	 */
	parse: function(data){
		if( $.isArray(data) ){
			return WebrickGUI._renderer['blocks']( {'content': data} );
		}

		if( typeof data == 'string' ){
			return WebrickGUI._renderer['raw']( {'content': data} );
		}

		if( $.isPlainObject(data) ){
			if( !('content' in data) ){
				data['content'] = '';
			}

			// parse 'element name': {attributes}
			if( !('render' in data) ){
				data = WebrickGUI.parse_shortHTML(data);
			}

			let renderer = WebrickGUI.parse;
			if( 'render' in data && data['render'] in WebrickGUI._renderer ){
				renderer = WebrickGUI._renderer[ data['render'] ];
			}else{
				data = data['content'];
			}

			return renderer( data );
		}

		return $();		// empty DOM object
	},

	/**
	 * set renderer
	 */
	setRenderer: function(rendererName, func){
		if( typeof rendererName != 'string' ){
			return false;
		}
		if( typeof func != 'function' ){
			return false;
		}
		_renderer[rendererName] = func;
		return true;
	},

	/**
	 * parse short html render style: 'element name': {attributes}
	 */
	parse_shortHTML: function(data){
		$.each( data, (key, val) => {
			if( key != 'content' ){
				data['render']    = 'html';
				data['element']   = key;
				data['attribute'] = val;
				return false;
			}
		});
		return data
	},

	/**
	 * default renderers
	 */
	defaultRenderers: {

		/**
		 * raw renderer
		 */
		raw: function(data){
			let htmlstr = data['content'] || '';
			if( typeof htmlstr != 'string' ){
				htmlstr = JSON.stringify( htmlstr );
			}
			return $.parseHTML( htmlstr );
		},

		/**
		 * blocks renderer
		 *
		 * @param Object data
		 */
		blocks: function(data){

			let attribute = data['attribute'] || {};
			let contents  = data['content'] || [];
			let result    = $('<div></div>', attribute);

			if( !$.isArray(contents) ){
				contents = [ contents ];
			}
			contents.forEach( function( value ){
				let block = $('<div></div>').append( WebrickGUI.parse(value) );
				result.append( block );
			});

			return result;
		},

		/**
		 * html renderer
		 *
		 * @param Object data
		 */
		html: function(data){

			let tag       = data['element'] || {};
			let attribute = data['attribute'] || {};
			let content   = data['content'] || {};
			let result    = $('<' + tag + '></' + tag + '>', attribute);

			if( $.isArray(content) ){
				content.forEach( function( value ){
					result.append( WebrickGUI.parse(value) );
				});
			}else{
				result.append( WebrickGUI.parse(content) );
			}

			return result;
		},

	}

};

