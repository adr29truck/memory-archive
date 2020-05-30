$(window).bind("load", function () {
  $('.loader-page')[0].style = 'width: 0;'
  setTimeout(function () {
    $('.loader-page')[0].outerHTML = ''
  }, 205)

  if (document.querySelectorAll('.alert').length > 0) {
    $('.alert').each( function (key, el) {
      alert_text = el.innerHTML
      if (el.classList.contains('alert-danger') === true) {
        status = 'alert-danger'
      } else if (el.classList.contains('alert-valid') === true){
        status = 'alert-valid'
      } else {
        status = ''
      }
      M.toast({html: alert_text, classes: status })
    })
  }
});

document.addEventListener('DOMContentLoaded', () => {

  // Get all "navbar-burger" elements
  const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);

  // Check if there are any navbar burgers
  if ($navbarBurgers.length > 0) {

    // Add a click event on each of them
    $navbarBurgers.forEach(el => {
      el.addEventListener('click', () => {

        // Get the target from the "data-target" attribute
        const target = el.dataset.target;
        const $target = document.getElementById(target);

        // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
        el.classList.toggle('is-active');
        $target.classList.toggle('is-active');

      });
    });
  }

  // init Infinite Scroll
  $('.article-feed').infiniteScroll({
    path: '.pagination__next',
    append: 'figure',
    status: '.scroller-status',
    hideNav: '.pagination',
    prefill: true,
  });

  $('.article-feed').on('append.infiniteScroll', function(event, response, path, items ) {
    $(items).find('.materialboxed').materialbox();
  });

  // init Materialize
  $('.materialboxed').materialbox();
  var elems = $('.slider');
  var options = {
    'duration': 500,
    'height': 400
  }
  var instances = M.Slider.init(elems, options);
  
  $('.collapsible').collapsible();
  
  // Fetch higher res images if not on mobile
  // TODO: Make the transition smooth
  // The new image should display first when fully fetched
  $(function() {      
    let isMobile = window.matchMedia("only screen and (max-width: 760px)").matches;

    if (isMobile == false) {
      
      $('.slides > li > img').each(function (el) {
        console.log(el)
        if (el.backgroundImage == 'url(/img/hero_festival-min.jpg)') {
          el.src = 'url(/img/hero_festival.jpg)'
        } else if (el.backgroundImage == 'url(/img/hero_sunset-min.jpg)') {
          el.src = 'url(/img/hero_sunset.jpg)'
        }
      })
    }
 });
});

function modalShow(el) {
  $(el).parent().find('.modal')[0].style.display = 'block';
}

function modalHide(el) {
  $(el).parent()[0].style.display = 'none';
}

function flash(elem) {
  console.log('FLAAASH')
  $(elem)[0].classList.remove('alert-initial')
}

function getFileData(myFile) {

  var filename = myFile.files[0].name;
  if (myFile.files.length > 1) {
    filename += " +"
    filename += myFile.files.length - 1
    filename += " "
  }
  $(myFile).parent().find('.file-label')[0].innerHTML = filename
}


function expandNav(el) {
  $(el).parent().children()[1].classList.toggle('expanded')
}


function hideAlert(el) {
  $(el).parent().parent()[0].outerHTML = ''
}

$('#textarea1').val('New Text');
  M.textareaAutoResize($('#textarea1'));