/*
 * Author:      ALL MEMBER (SHARED FILE)
 * Description: Client-side JavaScript (bar chart, UI interactions)
 * Date:        23/5/2026
 */
// =====================================================
// InsightLearn - Client-Side JavaScript
// =====================================================

// Run after DOM is ready
document.addEventListener('DOMContentLoaded', function () {
    highlightActiveNav();
    initNavToggle();
    initOptionSelection();
    initQuizNavigator();
});

// -- Active navigation highlighting --
function highlightActiveNav() {
    var currentPath = window.location.pathname.toLowerCase();
    var navLinks = document.querySelectorAll('.nav-menu a');

    navLinks.forEach(function (link) {
        var href = link.getAttribute('href');
        if (!href) return;

        var linkPath = href.toLowerCase().replace('~/', '/');

        // Match current page to nav link
        if (currentPath.endsWith(linkPath.split('/').pop()) ||
            (linkPath.includes('default.aspx') && (currentPath === '/' || currentPath.endsWith('default.aspx')))) {
            link.classList.add('active');
        }
    });
}

// -- Mobile navigation toggle --
function initNavToggle() {
    var toggle = document.getElementById('navToggle');
    var menu = document.getElementById('navMenu');

    if (toggle && menu) {
        toggle.addEventListener('click', function () {
            menu.classList.toggle('open');
        });

        // Close menu when a link is clicked
        menu.querySelectorAll('a').forEach(function (link) {
            link.addEventListener('click', function () {
                menu.classList.remove('open');
            });
        });
    }
}

// -- Quiz answer option selection (visual highlight) --
function initOptionSelection() {
    var optionItems = document.querySelectorAll('.option-item');
    optionItems.forEach(function (item) {
        var radio = item.querySelector('input[type="radio"]');
        if (!radio) return;

        // Check initial state
        if (radio.checked) item.classList.add('selected');

        radio.addEventListener('change', function () {
            // Remove selected from all options in this group
            var groupName = radio.name;
            document.querySelectorAll('input[name="' + groupName + '"]').forEach(function (r) {
                r.closest('.option-item').classList.remove('selected');
            });
            // Add selected to current
            item.classList.add('selected');

            // Mark question as answered in navigator
            markQuestionAnswered();
        });
    });
}

// -- Quiz question navigator --
function initQuizNavigator() {
    var navBtns = document.querySelectorAll('.q-nav-btn');
    navBtns.forEach(function (btn) {
        btn.addEventListener('click', function () {
            var qIndex = btn.getAttribute('data-question');
            if (qIndex !== null) {
                navigateToQuestion(parseInt(qIndex));
            }
        });
    });
}

// Marks the current question as answered in the navigator
function markQuestionAnswered() {
    var currentBtn = document.querySelector('.q-nav-btn.current');
    if (currentBtn && !currentBtn.classList.contains('flagged')) {
        currentBtn.classList.add('answered');
    }
}

// Navigate to a specific question number (used by hidden field + postback approach)
function navigateToQuestion(qNum) {
    var hiddenField = document.getElementById('hdnTargetQuestion');
    if (hiddenField) {
        hiddenField.value = qNum;
        var btn = document.getElementById('btnNavigate');
        if (btn) btn.click();
    }
}

// -- Progress bar animation --
function animateProgressBars() {
    var bars = document.querySelectorAll('.progress-bar-fill');
    bars.forEach(function (bar) {
        var target = bar.getAttribute('data-width') || bar.style.width;
        bar.style.width = '0';
        setTimeout(function () {
            bar.style.width = target;
        }, 100);
    });
}

window.addEventListener('load', animateProgressBars);

// -- Confirm delete dialog --
function confirmDelete(itemName) {
    return confirm('Are you sure you want to delete "' + itemName + '"? This action cannot be undone.');
}

// -- Course search (client-side filter for instant results) --
function filterCoursesClient() {
    var input = document.getElementById('txtSearchCourses');
    if (!input) return;

    input.addEventListener('input', function () {
        // Server-side filtering handles the main search via postback
        // Client-side: just ensure the form auto-submits after a short delay
    });
}

// -- Auto-submit search after typing pause (300ms debounce) --
function setupSearchDebounce(inputId, formId) {
    var input = document.getElementById(inputId);
    var timer;
    if (!input) return;

    input.addEventListener('keyup', function (e) {
        if (e.key === 'Enter') {
            clearTimeout(timer);
            document.getElementById(formId).submit();
            return;
        }
        clearTimeout(timer);
        timer = setTimeout(function () {
            // Trigger server-side search via button click
            var searchBtn = document.getElementById('btnSearch');
            if (searchBtn) searchBtn.click();
        }, 350);
    });
}

// -- Quiz flag for review toggle --
function toggleFlag(questionNum) {
    var btn = document.querySelector('.q-nav-btn[data-question="' + questionNum + '"]');
    if (!btn) return;

    if (btn.classList.contains('flagged')) {
        btn.classList.remove('flagged');
        if (btn.classList.contains('answered')) {
            // keep answered state
        }
    } else {
        btn.classList.add('flagged');
    }
}

// -- Chart rendering (simple SVG bar chart for dashboard) --
function renderBarChart(canvasId, labels, values, maxValue) {
    var container = document.getElementById(canvasId);
    if (!container) return;

    var width    = container.offsetWidth || 480;
    var height   = 210;
    var padL     = 42;   // left  — y-axis labels
    var padR     = 12;   // right
    var padT     = 28;   // top   — score label above tallest bar
    var padB     = 48;   // bottom — date labels
    var chartW   = width - padL - padR;
    var chartH   = height - padT - padB;
    var barCount = labels.length;
    var slotW    = chartW / barCount;
    var barW     = Math.max(12, Math.floor(slotW * 0.55));
    var chartMax = maxValue || (Math.max.apply(null, values) * 1.2) || 100;
    var baseY    = padT + chartH;   // y coordinate of the x-axis

    var svg = ['<svg width="100%" height="' + height + '" xmlns="http://www.w3.org/2000/svg">'];

    // Horizontal grid lines + Y-axis percentage labels at 0, 50, 100
    [0, 50, 100].forEach(function (pct) {
        var gy = baseY - Math.round((pct / chartMax) * chartH);
        svg.push('<line x1="' + padL + '" y1="' + gy + '" x2="' + (width - padR) + '" y2="' + gy +
                 '" stroke="#F1F5F9" stroke-width="1"/>');
        svg.push('<text x="' + (padL - 6) + '" y="' + (gy + 4) +
                 '" text-anchor="end" font-size="9" fill="#94A3B8">' + pct + '</text>');
    });

    // Y-axis line
    svg.push('<line x1="' + padL + '" y1="' + padT + '" x2="' + padL + '" y2="' + baseY +
             '" stroke="#E2E8F0" stroke-width="1"/>');
    // X-axis line
    svg.push('<line x1="' + padL + '" y1="' + baseY + '" x2="' + (width - padR) + '" y2="' + baseY +
             '" stroke="#E2E8F0" stroke-width="1"/>');

    // Bars, score labels, date labels
    values.forEach(function (val, i) {
        var cx   = padL + i * slotW + slotW / 2;            // horizontal centre of this bar slot
        var bx   = Math.round(cx - barW / 2);               // bar left edge
        var hasScore = val > 0;
        var barH     = hasScore
                         ? Math.max(4, Math.round((val / chartMax) * chartH))
                         : Math.round(chartH * 0.08);       // empty-day placeholder bar
        var by       = baseY - barH;                        // bar top edge
        var barColor = hasScore ? '#7C3AED' : '#CBD5E1';    // purple if scored, gray if no quiz
        var barOp    = hasScore ? '0.85'    : '0.5';

        // Bar
        svg.push('<rect x="' + bx + '" y="' + by + '" width="' + barW + '" height="' + barH +
                 '" rx="4" fill="' + barColor + '" opacity="' + barOp + '"/>');

        // Score label above bar — only for days that have a quiz result
        if (hasScore && by > padT + 14) {
            svg.push('<text x="' + cx + '" y="' + (by - 6) +
                     '" text-anchor="middle" font-size="10" font-weight="600" fill="#475569">' +
                     val + '%</text>');
        }

        // Full date label below x-axis
        svg.push('<text x="' + cx + '" y="' + (baseY + 16) +
                 '" text-anchor="middle" font-size="10" fill="#94A3B8">' +
                 (labels[i] || '') + '</text>');
    });

    svg.push('</svg>');
    container.innerHTML = svg.join('');
}

// -- Form validation helpers --
function validatePasswordMatch(pass, confirm) {
    var p = document.getElementById(pass);
    var c = document.getElementById(confirm);
    if (!p || !c) return true;
    if (p.value !== c.value) {
        c.setCustomValidity('Passwords do not match.');
        return false;
    }
    c.setCustomValidity('');
    return true;
}

// -- Enroll button loading state --
function setEnrollLoading(btn) {
    btn.disabled = true;
    btn.innerText = 'Enrolling...';
}
