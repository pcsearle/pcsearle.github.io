// Shuffles the children of any .field-gallery container on each page load,
// so a growing photo collection doesn't look the same every visit.
document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll(".field-gallery").forEach(function (grid) {
    var items = Array.prototype.slice.call(grid.children);

    // Fisher-Yates shuffle
    for (var i = items.length - 1; i > 0; i--) {
      var j = Math.floor(Math.random() * (i + 1));
      var tmp = items[i];
      items[i] = items[j];
      items[j] = tmp;
    }

    items.forEach(function (item) {
      grid.appendChild(item); // moves existing node, reordering it
    });
  });
});
