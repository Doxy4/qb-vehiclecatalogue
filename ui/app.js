let currentTab = ".cars-page-container";
var playerJob = "";

$(document).on('click', '.nav-item-close', function(){
  $.post('https://qb-vehiclecatalogue/escape')
});

$(document).keyup(function(e) {
  if (e.key === "Escape") {
    $.post('https://qb-vehiclecatalogue/escape')
 }
});

$(".nav-item").click(function () {
  if ($(this).hasClass("active-nav") == false) {
    fidgetSpinner($(this).data("page"));
    currentTab = $(this).data("page");
  }
});

$("nav-li").click(function () {
  if ($(this).hasClass("li-nav") == false) {
  }
});

function colortonumber(color) {
  switch (color) {
    case "gray":
      return 1;
    case "red":
      return 27;
    case "green":
      return 92;
    case "amber":
      return 88;
    case "blue":
      return 64;
    default:
      return 1;
  }
}

var color = "gray"

window.addEventListener("load", () => {

  const colorItems = document.querySelectorAll('.color-item');
  colorItems.forEach( item => {
      item.addEventListener('click', function() {
          const idSelected = this.id;
          color = idSelected
          // document.body.className = idSelected;
      })
  })

})

function buyCar(name) {
  fetch("https://qb-vehiclecatalogue/buycar", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      carName: name,
      color: colortonumber(color),
    }),
  });
}

function testCar(name) {
  fetch("https://qb-vehiclecatalogue/testcar", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      carName: name,
    }),
  });
}

$(document).ready(() => {
  $(".nav-item").click(function () {
    if ($(this).hasClass("active-nav") == false) {
      fidgetSpinner($(this).data("page"));
      currentTab = $(this).data("page");
    }
  });

  function fidgetSpinner(page) {
    $(".close-all").fadeOut(0);
    $(".container-load").fadeIn(0);
    setTimeout(() => {
      $(".container-load").fadeOut(0);
      $(page).fadeIn(0);
    }, 300);
  }
  
  function timeShit() {
    let localDate = new Date();
    const myTimeZone = Intl.DateTimeFormat().resolvedOptions().timeZone
    date = localDate.toLocaleDateString("en-US", {
      timeZone: myTimeZone,
    });
    time = localDate.toLocaleTimeString("en-US", {
      timeZone: myTimeZone,
    });
    $(".date").html(date);
    $(".time").html(time);
  }
  
  setInterval(timeShit, 1000);
  
  function addTag(tagInput) {
    $(".tags-holder").prepend(`<div class="tag">${tagInput}</div>`);
  
    $.post(
      `https://${GetParentResourceName()}/newTag`,
      JSON.stringify({
        id: $(".manage-profile-citizenid-input").val(),
        tag: tagInput,
      })
    );
  }

  window.addEventListener("message", function (event) {
    let eventData = event.data;
    if (eventData.type == "show") {
      if (eventData.enable == true) {
        playerJob = eventData.job;

        $("body").fadeIn(0);
        $(".close-all").css("filter", "none");
        $(".close-all").fadeOut(0);
        if (!currentTab) {
          currentTab = ".cars-page-container";
        }
        $(currentTab).slideDown(250);
        timeShit();
      } else {
        $("body").slideUp(250);
        $(".close-all").slideUp(250);
      }
    } else if (eventData.type == "data") {
      $(".name").html(eventData.name);
    }
  });
});