// Shuffles the children of any .field-gallery container on each page load,
// so a growing photo collection doesn't look the same every visit. Any item
// marked data-pinned="true" always stays first (e.g. a headshot you want
// visible on every visit) -- only the rest get shuffled.
document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll(".field-gallery").forEach(function (grid) {
    var allItems = Array.prototype.slice.call(grid.children);
    var pinned = allItems.filter(function (item) {
      return item.getAttribute("data-pinned") === "true";
    });
    var items = allItems.filter(function (item) {
      return item.getAttribute("data-pinned") !== "true";
    });

    // Fisher-Yates shuffle of the non-pinned items
    for (var i = items.length - 1; i > 0; i--) {
      var j = Math.floor(Math.random() * (i + 1));
      var tmp = items[i];
      items[i] = items[j];
      items[j] = tmp;
    }

    pinned.concat(items).forEach(function (item) {
      grid.appendChild(item); // moves existing node, reordering it
    });
  });
});
