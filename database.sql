/*
 * Author:      Chan Kar Jun, Ng Ern Chi, Foo Kim Chean, Ian Lim, Oswald Loh Kar Tzun
 * Description: InsightLearn Database Schema and Sample Data
 * Date:        23/5/2026
 */
-- ============================================================
-- InsightLearn Database Setup Script
-- SQL Server LocalDB (.mdf)
-- ============================================================
-- HOW TO SET UP:
-- 1. In Visual Studio 2019, right-click App_Data > Add > New Item
-- 2. Select "SQL Server Database", name it InsightLearn.mdf
-- 3. Open Server Explorer, expand the database, right-click > New Query
-- 4. Paste this script and execute (F5)
-- ============================================================

USE [InsightLearn]
GO

-- Drop tables in correct order to avoid FK constraint errors
IF OBJECT_ID('Attempt_Answers', 'U') IS NOT NULL DROP TABLE Attempt_Answers;
IF OBJECT_ID('Quiz_Attempts', 'U') IS NOT NULL DROP TABLE Quiz_Attempts;
IF OBJECT_ID('Lesson_Progress', 'U') IS NOT NULL DROP TABLE Lesson_Progress;
IF OBJECT_ID('Questions', 'U') IS NOT NULL DROP TABLE Questions;
IF OBJECT_ID('Quizzes', 'U') IS NOT NULL DROP TABLE Quizzes;
IF OBJECT_ID('Enrollment', 'U') IS NOT NULL DROP TABLE Enrollment;
IF OBJECT_ID('Lessons', 'U') IS NOT NULL DROP TABLE Lessons;
IF OBJECT_ID('Courses', 'U') IS NOT NULL DROP TABLE Courses;
IF OBJECT_ID('Users', 'U') IS NOT NULL DROP TABLE Users;
GO

-- =====================
-- USERS TABLE
-- =====================
CREATE TABLE Users (
    user_id     INT IDENTITY(1,1) PRIMARY KEY,
    name        NVARCHAR(100) NOT NULL,
    email       NVARCHAR(100) NOT NULL UNIQUE,
    password    NVARCHAR(100) NOT NULL,
    role        NVARCHAR(20)  NOT NULL DEFAULT 'student'
        CHECK (role IN ('admin', 'student'))
);
GO

-- =====================
-- COURSES TABLE
-- =====================
CREATE TABLE Courses (
    course_id   INT IDENTITY(1,1) PRIMARY KEY,
    course_name NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    category    NVARCHAR(100),
    thumbnail   NVARCHAR(300),
    published   BIT NOT NULL DEFAULT(0)
);
GO

-- =====================
-- LESSONS TABLE
-- =====================
CREATE TABLE Lessons (
    lesson_id       INT IDENTITY(1,1) PRIMARY KEY,
    course_id       INT NOT NULL REFERENCES Courses(course_id) ON DELETE CASCADE,
    lesson_title    NVARCHAR(200) NOT NULL,
    lesson_content  NVARCHAR(MAX),
    video_url       NVARCHAR(500)
);
GO

-- =====================
-- ENROLLMENT TABLE
-- =====================
CREATE TABLE Enrollment (
    enrollment_id   INT IDENTITY(1,1) PRIMARY KEY,
    user_id         INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    course_id       INT NOT NULL REFERENCES Courses(course_id) ON DELETE CASCADE,
    enrolled_date   DATETIME DEFAULT GETDATE()
);
GO

-- =====================
-- QUIZZES TABLE
-- =====================
CREATE TABLE Quizzes (
    quiz_id     INT IDENTITY(1,1) PRIMARY KEY,
    course_id   INT NOT NULL REFERENCES Courses(course_id) ON DELETE CASCADE,
    quiz_title  NVARCHAR(200) NOT NULL
);
GO

-- =====================
-- QUESTIONS TABLE
-- =====================
CREATE TABLE Questions (
    question_id     INT IDENTITY(1,1) PRIMARY KEY,
    quiz_id         INT NOT NULL REFERENCES Quizzes(quiz_id) ON DELETE CASCADE,
    question_text   NVARCHAR(MAX) NOT NULL,
    option_a        NVARCHAR(500),
    option_b        NVARCHAR(500),
    option_c        NVARCHAR(500),
    option_d        NVARCHAR(500),
    correct_answer  CHAR(1) CHECK (correct_answer IN ('A','B','C','D'))
);
GO

-- =====================
-- QUIZ ATTEMPTS TABLE
-- =====================
CREATE TABLE Quiz_Attempts (
    attempt_id      INT IDENTITY(1,1) PRIMARY KEY,
    user_id         INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    quiz_id         INT NOT NULL REFERENCES Quizzes(quiz_id) ON DELETE CASCADE,
    score           INT DEFAULT 0,
    attempt_date    DATETIME DEFAULT GETDATE()
);
GO

-- =====================
-- LESSON PROGRESS TABLE
-- =====================
CREATE TABLE Lesson_Progress (
    progress_id     INT IDENTITY(1,1) PRIMARY KEY,
    user_id         INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    lesson_id       INT NOT NULL REFERENCES Lessons(lesson_id) ON DELETE CASCADE,
    is_completed    BIT DEFAULT 0
);
GO

-- =====================
-- ATTEMPT ANSWERS TABLE
-- =====================
CREATE TABLE Attempt_Answers (
    answer_id       INT IDENTITY(1,1) PRIMARY KEY,
    attempt_id      INT NOT NULL REFERENCES Quiz_Attempts(attempt_id) ON DELETE CASCADE,
    question_id     INT NOT NULL REFERENCES Questions(question_id),
    selected_answer CHAR(1)
);
GO

-- ==============================================================
-- SAMPLE DATA
-- ==============================================================

-- Users (password stored as plain text for demo purposes)
-- Admin: admin@insightlearn.com / Admin@123
-- Students: john@student.com / Student@123, jane@student.com / Student@123
INSERT INTO Users (name, email, password, role) VALUES
('Admin User',  'admin@insightlearn.com', 'Admin@123',   'admin'),
('John Smith',  'john@student.com',       'Student@123', 'student'),
('Jane Doe',    'jane@student.com',       'Student@123', 'student'),
('Mike Johnson','mike@student.com',       'Student@123', 'student');
GO

-- Courses
INSERT INTO Courses (course_name, description, category, thumbnail, published) VALUES
('Introduction to Programming',       'Learn the fundamentals of programming using Python. Covers variables, loops, functions, and more.', 'Programming',      'prog_intro.png',     1),
('Web Development Fundamentals',      'Build beautiful, responsive websites using HTML, CSS, and JavaScript from scratch.',                'Web Development',  'webdev.png',         1),
('Data Structures & Algorithms',      'Deep dive into sorting algorithms, trees, graphs, and problem-solving techniques.',                 'Computer Science', 'dsa.png',            1),
('Calculus Fundamentals',             'Master derivatives, integrals, and limits with step-by-step guidance for STEM students.',           'Mathematics',      'calculus.png',       1),
('Data Analysis with Python',         'Analyze and visualize data using Python libraries like Pandas, Matplotlib and NumPy.',              'Data Science',     'dataanalysis.png',   1),
('UI/UX Design Principles',           'Create user-friendly interfaces with proven design principles, Figma workflows, and prototyping.', 'Design',           'uiux.png',           1);
GO

-- Lessons for Course 1 (Introduction to Programming)
INSERT INTO Lessons (course_id, lesson_title, lesson_content, video_url) VALUES
(1, 'Introduction to the Course',
 'Welcome to Introduction to Programming! In this course, you will learn the core building blocks of software development. We start from absolute zero – no experience required. By the end of the course, you will be able to write simple Python programs, understand logic flow, and solve basic problems through code.',
 'https://www.youtube.com/embed/rfscVS0vtbw'),

(1, 'Variables and Data Types',
 'A variable is a named storage location in memory. In Python, you do not need to declare types explicitly – Python figures it out automatically. Key data types include: int (whole numbers), float (decimal numbers), str (text strings), bool (True/False). Example: name = "Alice", age = 20, gpa = 3.75, is_student = True',
 'https://www.youtube.com/embed/cQT33yu9pY8'),

(1, 'Control Flow and Loops',
 'Control flow determines the order in which statements are executed. The if-elif-else structure allows your program to make decisions. Loops (for, while) allow repetition. Example: for i in range(5): print(i) will print 0 through 4. The while loop runs as long as a condition is True.',
 'https://www.youtube.com/embed/DZwmZ8Usvnk'),

(1, 'Functions and Modules',
 'Functions are reusable blocks of code. Define them with the def keyword. Parameters let you pass data in; return statements give data back. Modules are files containing related functions. Use import to load modules. Example: import math, then math.sqrt(16) returns 4.0.',
 'https://www.youtube.com/embed/9Os0o3wzS_I'),

(1, 'Lists, Tuples and Dictionaries',
 'Collections let you store multiple values. Lists are ordered and mutable: fruits = ["apple","banana","cherry"]. Tuples are ordered but immutable: point = (3, 4). Dictionaries store key-value pairs: person = {"name": "Alice", "age": 20}. Access values with person["name"].',
 'https://www.youtube.com/embed/W8KRzm-HUcc');

-- Lessons for Course 2 (Web Development Fundamentals)
INSERT INTO Lessons (course_id, lesson_title, lesson_content, video_url) VALUES
(2, 'Introduction to HTML',
 'HTML (HyperText Markup Language) is the backbone of every web page. It uses tags to define structure. Key tags: <html>, <head>, <body>, <h1>-<h6> for headings, <p> for paragraphs, <a> for links, <img> for images, <div> and <span> for grouping elements. HTML5 added semantic tags like <header>, <nav>, <main>, <footer>, and <article>.',
 'https://www.youtube.com/embed/qz0aGYrrlhU'),

(2, 'CSS Styling Basics',
 'CSS (Cascading Style Sheets) controls the visual presentation of HTML. Selectors target elements: element, .class, #id. Key properties: color, background-color, font-size, padding, margin, border. The box model: content + padding + border + margin. CSS can be external (stylesheet), internal (<style> tag), or inline (style attribute).',
 'https://www.youtube.com/embed/1PnVor36_40'),

(2, 'Flexbox and Grid Layouts',
 'Flexbox makes one-dimensional layouts easy. Set display: flex on a container, then control direction, alignment, and wrapping. CSS Grid handles two-dimensional layouts. Define columns with grid-template-columns: repeat(3, 1fr). Use grid-gap for spacing. These modern layout tools replace the old float-based approach.',
 'https://www.youtube.com/embed/JJSoEo8JSnc'),

(2, 'JavaScript Basics',
 'JavaScript adds interactivity to web pages. Variables: let name = "Alice". Functions: function greet() { ... }. DOM manipulation: document.getElementById("myId").innerHTML = "Hello". Events: element.addEventListener("click", function() { ... }). Arrays and objects work similarly to Python lists and dictionaries.',
 'https://www.youtube.com/embed/W6NZfCO5SIk'),

(2, 'Responsive Web Design',
 'Responsive design ensures your site looks good on all screen sizes. Use the viewport meta tag: <meta name="viewport" content="width=device-width, initial-scale=1.0">. Media queries apply styles at specific widths: @media (max-width: 768px) { ... }. Use percentages and flexible units (em, rem, vw, vh) instead of fixed pixel values.',
 'https://www.youtube.com/embed/srvUrASNj0s');

-- Lessons for Course 3 (Data Structures & Algorithms)
INSERT INTO Lessons (course_id, lesson_title, lesson_content, video_url) VALUES
(3, 'Big O Notation',
 'Big O notation describes algorithm efficiency. O(1) is constant time. O(n) is linear. O(n²) is quadratic. O(log n) is logarithmic. We analyze both time complexity (speed) and space complexity (memory). When choosing algorithms, pick the one with the best Big O for your use case.',
 'https://www.youtube.com/embed/__vX2ms4roE'),

(3, 'Arrays and Linked Lists',
 'Arrays store elements in contiguous memory. Access is O(1) by index. Insertion/deletion at the middle is O(n). Linked Lists store elements in nodes with pointers to the next node. Access is O(n), but insertion/deletion at front is O(1). Use arrays when you need fast access; use linked lists when you need fast insertions.',
 'https://www.youtube.com/embed/njTh_OwMljA'),

(3, 'Stacks and Queues',
 'A Stack follows LIFO (Last In, First Out). Operations: push (add to top), pop (remove from top). Used in: function call stacks, undo operations, expression evaluation. A Queue follows FIFO (First In, First Out). Operations: enqueue (add to back), dequeue (remove from front). Used in: task scheduling, breadth-first search.',
 'https://www.youtube.com/embed/wjI1WNcIntg'),

(3, 'Binary Search Trees',
 'A Binary Search Tree (BST) is a tree where each node has at most two children. Left child < parent < right child. Operations: search O(log n), insert O(log n), delete O(log n) on average. In-order traversal visits nodes in sorted order. BSTs degrade to O(n) if not balanced.',
 'https://www.youtube.com/embed/cySVml6e_Fc'),

(3, 'Sorting Algorithms',
 'Common sorting algorithms: Bubble Sort O(n²) – repeatedly swaps adjacent elements. Selection Sort O(n²) – finds minimum and places it. Insertion Sort O(n²) – builds sorted array one element at a time. Merge Sort O(n log n) – divide and conquer approach. Quick Sort O(n log n) average – pivoting strategy.',
 'https://www.youtube.com/embed/kPRA0W1kECg');

-- Lessons for Course 4 (Calculus Fundamentals)
INSERT INTO Lessons (course_id, lesson_title, lesson_content, video_url) VALUES
(4, 'Limits and Continuity',
 'A limit describes the value a function approaches as the input approaches a value. lim(x→2) (x² - 4)/(x - 2) = 4. Continuity means no breaks, jumps, or holes in the graph. Three conditions for continuity at a point c: f(c) is defined, the limit exists, and the limit equals f(c).',
 'https://www.youtube.com/embed/kfF40MiS7zA'),

(4, 'Introduction to Derivatives',
 'The derivative measures the rate of change. f''(x) = lim(h→0) [f(x+h) - f(x)] / h. Basic rules: Power Rule – d/dx(xⁿ) = nxⁿ⁻¹. Product Rule – (uv)'' = u''v + uv''. Quotient Rule – (u/v)'' = (u''v - uv'')/v². Chain Rule – d/dx[f(g(x))] = f''(g(x)) · g''(x).',
 'https://www.youtube.com/embed/rAof9Ld5sOg'),

(4, 'Applications of Derivatives',
 'Derivatives have many real-world applications. Finding maximum and minimum values: set f''(x) = 0 and solve. The second derivative test confirms if it is max or min. Related rates problems use derivatives to relate changing quantities over time. Optimization: minimize cost, maximize profit, minimize distance.',
 'https://www.youtube.com/embed/q74V4yWBdSI'),

(4, 'Introduction to Integration',
 'Integration is the reverse of differentiation. The indefinite integral ∫f(x)dx = F(x) + C where F''(x) = f(x). The definite integral ∫[a,b] f(x)dx gives the area under the curve from a to b. Fundamental Theorem of Calculus: the definite integral of f from a to b is F(b) - F(a).',
 'https://www.youtube.com/embed/rfG8ce4nNh0');

-- Lessons for Course 5 (Data Analysis with Python)
INSERT INTO Lessons (course_id, lesson_title, lesson_content, video_url) VALUES
(5, 'Introduction to NumPy',
 'NumPy is the foundation of scientific Python. It provides the ndarray object for fast array operations. Create arrays: np.array([1,2,3]), np.zeros((3,3)), np.arange(0,10,2). Array math is element-wise by default. Vectorized operations are much faster than Python loops. Shape, reshape, and indexing are essential skills.',
 'https://www.youtube.com/embed/GB9ByFAIAH4'),

(5, 'Data Manipulation with Pandas',
 'Pandas provides DataFrame and Series objects for data analysis. Read data: pd.read_csv("file.csv"). Explore: df.head(), df.describe(), df.info(). Select columns: df["column"] or df[["col1","col2"]]. Filter rows: df[df["age"] > 18]. Group data: df.groupby("category").mean(). Handle missing values: df.dropna(), df.fillna(0).',
 'https://www.youtube.com/embed/vmEHCJofslg'),

(5, 'Data Visualization with Matplotlib',
 'Matplotlib creates charts and graphs. Basic plot: plt.plot(x, y). Bar chart: plt.bar(categories, values). Histogram: plt.hist(data, bins=10). Scatter plot: plt.scatter(x, y). Always add labels: plt.xlabel(), plt.ylabel(), plt.title(). Show plot: plt.show(). Save plot: plt.savefig("chart.png").',
 'https://www.youtube.com/embed/3Xc3CA655Y4');

-- Lessons for Course 6 (UI/UX Design Principles)
INSERT INTO Lessons (course_id, lesson_title, lesson_content, video_url) VALUES
(6, 'Principles of Good Design',
 'Good design follows key principles: Contrast – make important elements stand out. Alignment – create visual order. Proximity – group related elements. Repetition – maintain consistency. The 8pt grid system helps maintain consistent spacing. White space (negative space) improves readability and focus.',
 'https://www.youtube.com/embed/a5KYlHNKQB8'),

(6, 'User Research and Personas',
 'User research informs design decisions. Methods include: interviews, surveys, usability testing, card sorting. A persona is a fictional user based on real research. Include: name, age, goals, frustrations, technical comfort. Personas help teams keep users at the center of design decisions. User stories follow: As a [persona], I want [goal] so that [benefit].',
 'https://www.youtube.com/embed/ZAqL4f4FH3w'),

(6, 'Wireframing and Prototyping',
 'Wireframes are low-fidelity sketches of layouts. They show structure without visual design. Tools: pen/paper, Balsamiq, Figma. Prototypes are interactive mockups. Low-fidelity: paper, quick digital. High-fidelity: looks and feels like the real product. Usability testing on prototypes saves time and money before development.',
 'https://www.youtube.com/embed/qpH7-KFWZRI');

GO

-- ==========================
-- QUIZZES
-- ==========================
INSERT INTO Quizzes (course_id, quiz_title) VALUES
(1, 'Python Basics Quiz'),
(1, 'Functions and Collections Quiz'),
(2, 'HTML & CSS Assessment'),
(2, 'JavaScript Fundamentals Quiz'),
(3, 'Algorithm Complexity Quiz'),
(4, 'Calculus Basics Quiz'),
(5, 'Pandas and NumPy Quiz'),
(6, 'Design Principles Quiz');
GO

-- ==========================
-- QUESTIONS for Quiz 1 (Python Basics)
-- ==========================
INSERT INTO Questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer) VALUES
(1, 'What keyword is used to define a function in Python?',
 'function', 'def', 'define', 'func', 'B'),

(1, 'Which of the following is a valid Python variable name?',
 '2myVar', 'my-var', 'my_var', 'my var', 'C'),

(1, 'What is the output of print(type(3.14))?',
 "<class 'int'>", "<class 'float'>", "<class 'double'>", "<class 'number'>", 'B'),

(1, 'Which operator is used for integer division in Python?',
 '/', '//', '%', '**', 'B'),

(1, 'What does the len() function return?',
 'The largest element', 'The sum of all elements', 'The number of items in an object', 'The type of the object', 'C'),

(1, 'What is the correct way to create a list in Python?',
 'list = (1, 2, 3)', 'list = {1, 2, 3}', 'list = [1, 2, 3]', 'list = <1, 2, 3>', 'C'),

(1, 'Which statement is used to exit a loop early in Python?',
 'exit', 'stop', 'break', 'return', 'C'),

(1, 'What is the result of 5 ** 2 in Python?',
 '10', '25', '52', '7', 'B'),

(1, 'How do you add a comment in Python?',
 '// This is a comment', '/* comment */', '# This is a comment', '-- comment', 'C'),

(1, 'What does the range(1, 10, 2) function produce?',
 '1, 2, 3, ..., 9', '1, 3, 5, 7, 9', '2, 4, 6, 8, 10', '1, 2, 4, 6, 8', 'B');

-- ==========================
-- QUESTIONS for Quiz 2 (Functions and Collections)
-- ==========================
INSERT INTO Questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer) VALUES
(2, 'Which collection type is immutable in Python?',
 'List', 'Dictionary', 'Tuple', 'Set', 'C'),

(2, 'How do you access a dictionary value by key?',
 'dict.get(key)', 'dict[key]', 'Both A and B are correct', 'dict.value(key)', 'C'),

(2, 'What does a function return if no return statement is specified?',
 '0', 'False', 'None', 'Empty string', 'C'),

(2, 'Which method adds an element to the end of a list?',
 'list.add()', 'list.push()', 'list.append()', 'list.insert()', 'C'),

(2, 'What is a lambda function?',
 'A function defined with the lambda keyword', 'An anonymous one-line function', 'A function that returns nothing', 'Both A and B', 'D');

-- ==========================
-- QUESTIONS for Quiz 3 (HTML & CSS)
-- ==========================
INSERT INTO Questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer) VALUES
(3, 'Which HTML tag is used for the largest heading?',
 '<h6>', '<h1>', '<header>', '<heading>', 'B'),

(3, 'What does CSS stand for?',
 'Computer Style Sheets', 'Cascading Style Sheets', 'Creative Style Sheets', 'Colorful Style Sheets', 'B'),

(3, 'How do you select an element with id="main" in CSS?',
 '.main', '*main', '#main', 'id=main', 'C'),

(3, 'Which CSS property controls text size?',
 'text-size', 'font-size', 'text-style', 'font-style', 'B'),

(3, 'What is the default display value for a <div> element?',
 'inline', 'block', 'flex', 'grid', 'B'),

(3, 'Which HTML5 element represents the main navigation?',
 '<menu>', '<nav>', '<navigation>', '<links>', 'B'),

(3, 'How do you link an external CSS file in HTML?',
 '<style src="file.css">', '<css href="file.css">', '<link rel="stylesheet" href="file.css">', '<link type="css" href="file.css">', 'C'),

(3, 'Which CSS property is used to add space inside an element?',
 'margin', 'spacing', 'padding', 'border', 'C');

-- ==========================
-- QUESTIONS for Quiz 4 (JavaScript)
-- ==========================
INSERT INTO Questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer) VALUES
(4, 'Which keyword declares a variable in modern JavaScript?',
 'var', 'let', 'const', 'Both let and const', 'D'),

(4, 'How do you write a function in JavaScript?',
 'def myFunc() {}', 'function myFunc() {}', 'func myFunc() {}', 'create myFunc() {}', 'B'),

(4, 'What does document.getElementById() return?',
 'An array of elements', 'A single DOM element', 'The HTML of the element', 'A CSS class', 'B'),

(4, 'Which method adds an event listener in JavaScript?',
 'addEventListener()', 'attachEvent()', 'bindEvent()', 'onEvent()', 'A'),

(4, 'What is the correct syntax for an if statement in JavaScript?',
 'if x > 10 then { }', 'if (x > 10) { }', 'if x > 10: { }', 'if [x > 10] { }', 'B');

-- ==========================
-- QUESTIONS for Quiz 5 (Algorithms)
-- ==========================
INSERT INTO Questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer) VALUES
(5, 'What is the time complexity of binary search?',
 'O(n)', 'O(n²)', 'O(log n)', 'O(1)', 'C'),

(5, 'Which sorting algorithm has the best average-case time complexity?',
 'Bubble Sort', 'Selection Sort', 'Insertion Sort', 'Merge Sort', 'D'),

(5, 'What does O(1) time complexity mean?',
 'The algorithm takes 1 second', 'The algorithm is very slow', 'The algorithm runs in constant time', 'The algorithm uses 1 unit of memory', 'C'),

(5, 'What is the worst-case time complexity of Quick Sort?',
 'O(n log n)', 'O(n²)', 'O(n)', 'O(log n)', 'B'),

(5, 'Which data structure uses LIFO order?',
 'Queue', 'Stack', 'Array', 'Linked List', 'B');

-- ==========================
-- QUESTIONS for Quiz 6 (Calculus)
-- ==========================
INSERT INTO Questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer) VALUES
(6, 'What is the derivative of x³?',
 '3x', '3x²', 'x²', '2x³', 'B'),

(6, 'What is the integral of 2x?',
 'x + C', '2 + C', 'x² + C', '2x² + C', 'C'),

(6, 'What does a limit describe?',
 'The maximum value of a function', 'The value a function approaches', 'The area under a curve', 'The rate of change', 'B'),

(6, 'The Power Rule states that d/dx(xⁿ) equals:',
 'xⁿ⁻¹', 'n·xⁿ', 'n·xⁿ⁻¹', '(n-1)·xⁿ', 'C'),

(6, 'What is the Fundamental Theorem of Calculus?',
 'Differentiation and integration are inverses of each other', 'All functions are differentiable', 'Every integral is solvable', 'Limits always exist', 'A');

-- ==========================
-- ENROLLMENT (sample data)
-- ==========================
-- John (user 2) enrolled in courses 1, 2, 3
INSERT INTO Enrollment (user_id, course_id, enrolled_date) VALUES
(2, 1, DATEADD(day, -30, GETDATE())),
(2, 2, DATEADD(day, -20, GETDATE())),
(2, 3, DATEADD(day, -10, GETDATE()));

-- Jane (user 3) enrolled in courses 1, 4
INSERT INTO Enrollment (user_id, course_id, enrolled_date) VALUES
(3, 1, DATEADD(day, -15, GETDATE())),
(3, 4, DATEADD(day, -5, GETDATE()));

-- Mike (user 4) enrolled in courses 2, 5
INSERT INTO Enrollment (user_id, course_id, enrolled_date) VALUES
(4, 2, DATEADD(day, -25, GETDATE())),
(4, 5, DATEADD(day, -8, GETDATE()));
GO

-- ==========================
-- LESSON PROGRESS (sample)
-- ==========================
-- John completed first 3 lessons of course 1, first 2 of course 2
INSERT INTO Lesson_Progress (user_id, lesson_id, is_completed) VALUES
(2, 1, 1), (2, 2, 1), (2, 3, 1), (2, 4, 0), (2, 5, 0),
(2, 6, 1), (2, 7, 1), (2, 8, 0), (2, 9, 0), (2, 10, 0);

-- Jane completed 2 lessons of course 1
INSERT INTO Lesson_Progress (user_id, lesson_id, is_completed) VALUES
(3, 1, 1), (3, 2, 1), (3, 3, 0), (3, 4, 0), (3, 5, 0);
GO

-- ==========================
-- QUIZ ATTEMPTS (sample)
-- ==========================
INSERT INTO Quiz_Attempts (user_id, quiz_id, score, attempt_date) VALUES
(2, 1, 85, DATEADD(day, -25, GETDATE())),
(2, 3, 92, DATEADD(day, -15, GETDATE())),
(2, 4, 68, DATEADD(day, -5, GETDATE())),
(3, 1, 75, DATEADD(day, -10, GETDATE())),
(4, 3, 88, DATEADD(day, -20, GETDATE()));
GO

PRINT 'InsightLearn database setup complete!';
PRINT 'Admin login: admin@insightlearn.com / Admin@123';
PRINT 'Student login: john@student.com / Student@123';
GO
