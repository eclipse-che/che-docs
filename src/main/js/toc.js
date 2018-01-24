
// https://github.com/ghiculescu/jekyll-table-of-contents
// scroll function

$(function() {
  $(window).scroll(function() {
    $(":header").each(function() {
      if ($(window).scrollTop() >= $(this).offset().top - 100) {
        var id = $(this).attr('id');
        var $cache = $('#toc ul');
        $('#toc ul li a').removeClass('active');
        $(' a[href="#' + id + '"]').addClass('active');
      }


    });
  });
});



$(document).ready(function () {
  var top = $('#toc').offset().top;
  $(window).scroll(function (event) {
    var y = $(this).scrollTop();
    if (y >= top)
      $('#toc').addClass('fixed');
    else
      $('#toc').removeClass('fixed');
    // $('#toc').width($('#toc').parent().width());
  });
});


// $(document).ready(function($){
//     $(window).scroll(function(){if($(this).scrollTop() > 200 ){
//        if($('#toc ul').css("position") == "absolute"){
//            $('#toc ul').css({"position":"fixed", "right": "initial", "top": "-20px"});
//        }
//     }else{
//         $('#toc ul').css({"position":"absolute", "right": "initial", "top": "0px"});
//     }
//   });

//
// $(function() {
//   function fixdiv() {
//     var $cache = $('#toc ul');
//     if ($(window).scrollTop() > 200)
//       $cache.css({
//         'margin-top': '-60px'
//       });
    // else {
    //   $cache.css({
    //     'margin-top': '200px',
    //     'background-color':'cyan'
    //   });
    // }
//   }
//   $(window).scroll(fixdiv);
//   fixdiv();
// });
//
//
// $(window).scroll(function() {
//    if($(window).scrollTop() + $(window).height() == $(document).height()) {
//      var $cache = $('#toc ul');
//      $cache.css({
//        'bottom': '150px'
//      });
//    }
// });





(function($){
  $.fn.toc = function(options) {
    var defaults = {
      noBackToTopLinks: false,
      title: '',
      minimumHeaders: 3,
      headers: 'h1, h2, h3, h4',
      listType: 'ol', // values: [ol|ul]
      showEffect: 'show', // values: [show|slideDown|fadeIn|none]
      showSpeed: 'slow' // set to 0 to deactivate effect
    },
    settings = $.extend(defaults, options);

    var headers = $(settings.headers).filter(function() {
      // get all headers with an ID
      var previousSiblingName = $(this).prev().attr( "name" );
      if (!this.id && previousSiblingName) {
        this.id = $(this).attr( "id", previousSiblingName.replace(/\./g, "-") );
      }
      return this.id;
    }), output = $(this);
    if (!headers.length || headers.length < settings.minimumHeaders || !output.length) {
      return;
    }

    if (0 === settings.showSpeed) {
      settings.showEffect = 'none';
    }

    var render = {
      show: function() { output.hide().html(html).show(settings.showSpeed); },
      slideDown: function() { output.hide().html(html).slideDown(settings.showSpeed); },
      fadeIn: function() { output.hide().html(html).fadeIn(settings.showSpeed); },
      none: function() { output.html(html); }
    };

    var get_level = function(ele) { return parseInt(ele.nodeName.replace("H", ""), 10); }
    var highest_level = headers.map(function(_, ele) { return get_level(ele); }).get().sort()[0];
    var return_to_top = '<i class="icon-arrow-up back-to-top"> </i>';

    var level = get_level(headers[0]),
      this_level,
      html = settings.title + " <"+settings.listType+">";
    headers.on('click', function() {
      if (!settings.noBackToTopLinks) {
        window.location.hash = this.id;
      }
    })
    .addClass('clickable-header')
    .each(function(_, header) {
      this_level = get_level(header);
      if (!settings.noBackToTopLinks && this_level === highest_level) {
        $(header).addClass('top-level-header').after(return_to_top);
      }
      if (this_level === level) // same level as before; same indenting
        html += "<li><a href='#" + header.id + "'>" + header.innerHTML + "</a>";
      else if (this_level <= level){ // higher level than before; end parent ol
        for(i = this_level; i < level; i++) {
          html += "</li></"+settings.listType+">"
        }
        html += "<li><a href='#" + header.id + "'>" + header.innerHTML + "</a>";
      }
      else if (this_level > level) { // lower level than before; expand the previous to contain a ol
        for(i = this_level; i > level; i--) {
          html += "<"+settings.listType+"><li>"
        }
        html += "<a href='#" + header.id + "'>" + header.innerHTML + "</a>";
      }
      level = this_level; // update for the next one
    });
    html += "</"+settings.listType+">";
    if (!settings.noBackToTopLinks) {
      $(document).on('click', '.back-to-top', function() {
        $(window).scrollTop(0);
        window.location.hash = '';
      });
    }

    render[settings.showEffect]();
  };
})(jQuery);
