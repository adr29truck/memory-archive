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


function expandNav(el) {
  $(el).parent().children()[1].classList.toggle('expanded')
}


function hideAlert(el) {
  $(el).parent().parent()[0].outerHTML = ''
}
