/**
 * SMS 2 - Auto Trigger Search
 * Automatically triggers the search button click when typing in student search fields.
 */
document.addEventListener("DOMContentLoaded", function () {

    function setupAutoSearch(inputId, buttonId) {
        const input = document.getElementById(inputId);
        const btn = document.getElementById(buttonId);

        if (input && btn) {
            let timeout = null;
            input.addEventListener("input", function () {
                clearTimeout(timeout);
                timeout = setTimeout(function () {
                    // Mag-auto search lang kung may laman na kahit papaano (e.g., >= 3 characters)
                    if (input.value.trim().length >= 3 || input.value.trim().length === 0) {
                        btn.click(); // Trigger the search button
                    }
                }, 500); // 500ms debounce
            });
        }
    }

    // Para sa Payment Collection Portal
    setupAutoSearch("searchStudentNumber", "btnSearchStudent");

    // Para sa Discount & Scholarship Application
    setupAutoSearch("searchStudentDiscount", "btnSearchBilling");
});
