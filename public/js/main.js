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
  });
});


function modalShow(el) {
  $(el).parent().find('.modal')[0].style.display = 'block';
}
function modalHide(el) {
  $(el).parent()[0].style.display = 'none';
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

// function hideModal() {
//   $('#cookie')[0].style.display = 'none'
// }

function expandNav(el) {
  $(el).parent().children()[1].classList.toggle('expanded')
}

// function draftToggle(el){
//   if ($(el).parent().parent().find('button')[0].innerHTML == 'Spara utkast') {
//     $(el).parent().parent().find('button')[0].innerHTML = 'Publicera'
//     $(el).parent().parent().find('button')[0].classList.add('is-danger')
//     $(el).parent().parent().find('button')[0].classList.remove('is-link')
//   } else {
//     $(el).parent().parent().find('button')[0].innerHTML = 'Spara utkast'
//     $(el).parent().parent().find('button')[0].classList.remove('is-danger')
//     $(el).parent().parent().find('button')[0].classList.add('is-link')
//   }
// }

function hideAlert(el) {
  $(el).parent().parent()[0].outerHTML = ''
}

// function expand(el) {

//   if ($(el).children().find('i')[0].innerHTML == 'keyboard_arrow_up') {
//     $(el).children()[0].innerHTML = 'expandera'

//     $(el).children().find('i')[0].innerHTML = 'keyboard_arrow_down'
//   } else {
//     $(el).children()[0].innerHTML = 'minimera'
//     $(el).children().find('i')[0].innerHTML = 'keyboard_arrow_up'

//   }
//   if ($(el).parent().parent().parent().children()[0].style.maxHeight == $(el).parent().parent().parent().children()[0].scrollHeight + "px") {
//     $(el).parent().parent().parent().children()[0].style.maxHeight = "50vh"
//   } else {
//     $(el).parent().parent().parent().children()[0].style.maxHeight = $(el).parent().parent().parent().children()[0].scrollHeight + "px"
//   }
// }