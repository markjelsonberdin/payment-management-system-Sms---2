/**
 * SMS 2 - Table Live Search
 * Automatically filters table rows as the user types in the search bar.
 */
document.addEventListener("DOMContentLoaded", function() {
    const searchInputs = document.querySelectorAll(".table-live-search-input");
    
    searchInputs.forEach(function(input) {
        input.addEventListener("input", function(e) {
            const query = e.target.value.toLowerCase();
            
            // Hanapin ang target table gamit ang data-table-target, 
            // kung wala, hanapin ang unang table na may class na .live-search-table
            let targetSelector = input.getAttribute("data-table-target");
            let table = null;
            
            if (targetSelector) {
                table = document.querySelector(targetSelector);
            } else {
                table = document.querySelector(".live-search-table");
            }
            
            if (!table) return;
            
            const tbody = table.querySelector("tbody");
            if (!tbody) return;
            
            const rows = tbody.querySelectorAll("tr");
            let hasVisibleRow = false;
            
            // Tanggalin yung nakaraang "no results" row kung meron
            const existingNoResults = tbody.querySelector(".live-search-no-results");
            if (existingNoResults) {
                existingNoResults.remove();
            }

            rows.forEach(function(row) {
                // Skip if empty state row
                if (row.classList.contains("empty-state-row")) {
                    return;
                }
                
                // Kapag walang text, skip (e.g. table headers na nasa tbody)
                const text = row.textContent.toLowerCase();
                
                if (text.includes(query)) {
                    row.style.display = "";
                    hasVisibleRow = true;
                } else {
                    row.style.display = "none";
                }
            });
            
            // Kapag walang nakitang match at may data yung table originally
            if (!hasVisibleRow && rows.length > 0 && !tbody.querySelector(".empty-state-row")) {
                const cols = rows[0].children.length || 1;
                const tr = document.createElement("tr");
                tr.className = "live-search-no-results text-center py-4";
                tr.innerHTML = `<td colspan="${cols}" class="text-muted py-5">
                                    <i class="fas fa-search fs-3 mb-2 d-block"></i>
                                    No matching records found for "<strong>${query}</strong>"
                                </td>`;
                tbody.appendChild(tr);
            }
        });
    });
});
