<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="true" %>
<%@ page import="com.example.assignment02.model.User" %>
<%@ page import="com.example.assignment02.dao.UserDao" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedUser");
    if (loggedInUser == null) {
        response.sendRedirect("login.html");
        return;
    }

    // ✅ Re-fetch from DB to get latest banned status
    UserDao userDao = new UserDao();
    loggedInUser = userDao.getUser(loggedInUser.getId());

    if (loggedInUser == null || loggedInUser.isBanned()) {
        session.invalidate();
        response.sendRedirect("login.html?error=banned");
        return;
    }

    // ✅ Update session with fresh data
    session.setAttribute("loggedUser", loggedInUser);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Personal Finance Dashboard</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f8fafc;
            color: #1e293b;
            line-height: 1.5;
        }

        .header {
            background: white;
            padding: 1.5rem 2rem;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h1 {
            font-size: 1.5rem;
            font-weight: 600;
            color: #1e293b;
        }

        .header-controls {
            display: flex;
            gap: 1rem;
            align-items: center;
        }

        .dropdown {
            position: relative;
            background: white;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            padding: 0.5rem 1rem;
            font-size: 0.875rem;
            cursor: pointer;
        }

        .date-picker {
            background: white;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            padding: 0.5rem 1rem;
            font-size: 0.875rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .export-btn {
            background: #ea580c;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 0.5rem 1rem;
            font-size: 0.875rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .main-content {
            padding: 2rem;
            max-width: 1400px;
            margin: 0 auto;
        }

        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }

        .card-title {
            font-size: 1rem;
            font-weight: 600;
            color: #374151;
        }

        .card-menu {
            background: none;
            border: none;
            color: #9ca3af;
            cursor: pointer;
            padding: 0.25rem;
        }

        .summary-block {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
            border-left: 4px solid transparent;
            display: flex;
            flex-direction: column;
            gap: 0.4rem;
        }
        .summary-block.income  { border-left-color: #10b981; }
        .summary-block.expense { border-left-color: #ef4444; }
        .summary-block.balance { border-left-color: #3b82f6; }
        .summary-block.overall { border-left-color: #8b5cf6; }
        .summary-icon {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
            margin-bottom: 0.25rem;
        }
        .summary-icon.income  { background: #d1fae5; color: #10b981; }
        .summary-icon.expense { background: #fee2e2; color: #ef4444; }
        .summary-icon.balance { background: #dbeafe; color: #3b82f6; }
        .summary-icon.overall { background: #ede9fe; color: #8b5cf6; }
        .summary-label {
            font-size: 0.78rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #6b7280;
        }
        .summary-amount {
            font-size: 1.75rem;
            font-weight: 700;
            color: #1e293b;
            line-height: 1.2;
        }
        .summary-sub {
            font-size: 0.78rem;
            color: #9ca3af;
        }

        .chart-section {
            grid-column: 1 / -1;
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 2rem;
        }

        .chart-container {
            height: 300px;
            position: relative;
            display: flex;
            align-items: end;
            justify-content: space-between;
            padding: 1rem;
            background: #f8fafc;
            border-radius: 8px;
            margin-top: 1rem;
        }

        .chart-bar {
            width: 40px;
            background: #e5e7eb;
            border-radius: 4px 4px 0 0;
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: end;
        }

        .chart-bar.active {
            background: linear-gradient(to top, #ea580c, #fb923c);
        }

        .chart-bar-income {
            background: #10b981;
            margin-bottom: 4px;
            border-radius: 4px;
        }

        .chart-bar-expense {
            background: #ea580c;
            border-radius: 4px;
        }

        .chart-labels {
            display: flex;
            justify-content: space-between;
            margin-top: 1rem;
            font-size: 0.75rem;
            color: #6b7280;
        }

        .expenses-breakdown {
            margin-top: 1rem;
        }

        .total-expenses {
            font-size: 1.75rem;
            font-weight: 700;
            margin-bottom: 1rem;
        }

        .period-tabs {
            display: flex;
            gap: 2rem;
            margin-bottom: 1rem;
            font-size: 0.875rem;
        }

        .period-tab {
            color: #6b7280;
            cursor: pointer;
        }

        .period-tab.active {
            color: #1e293b;
            font-weight: 600;
        }

        .period-amounts {
            display: flex;
            justify-content: space-between;
            margin-bottom: 1rem;
            font-size: 0.875rem;
            color: #6b7280;
        }

        .period-values {
            display: flex;
            justify-content: space-between;
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 1rem;
        }

        .color-bar {
            height: 6px;
            border-radius: 3px;
            background: linear-gradient(to right, #ea580c, #f59e0b, #eab308, #10b981);
            margin-bottom: 1rem;
        }

        .expense-categories {
            list-style: none;
        }

        .expense-category {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.5rem 0;
            border-bottom: 1px solid #f3f4f6;
        }

        .category-info {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .category-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
        }

        .dot-food { background: #ea580c; }
        .dot-entertainment { background: #f59e0b; }
        .dot-shopping { background: #eab308; }
        .dot-investment { background: #10b981; }

        .transactions-section {
            grid-column: 1 / -1;
        }

        .section-header {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 1rem;
        }

        .filters {
            display: flex;
            gap: 1rem;
        }

        .filter-btn {
            background: white;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            padding: 0.5rem 1rem;
            font-size: 0.875rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .transactions-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }

        .transactions-table th {
            text-align: left;
            padding: 1rem;
            font-size: 0.875rem;
            font-weight: 600;
            color: #6b7280;
            border-bottom: 1px solid #e5e7eb;
        }

        .transactions-table td {
            padding: 1rem;
            border-bottom: 1px solid #f3f4f6;
        }

        .status-success {
            background: #dcfce7;
            color: #16a34a;
            padding: 0.25rem 0.75rem;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .action-btn {
            background: none;
            border: none;
            color: #6b7280;
            cursor: pointer;
            padding: 0.25rem;
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            animation: fadeIn 0.3s ease;
        }

        .modal-content {
            background: white;
            border-radius: 12px;
            width: 500px;
            max-width: 90vw;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            animation: slideIn 0.3s ease;
        }

        .modal-header {
            padding: 1.5rem;
            border-bottom: 1px solid #e5e7eb;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-title {
            font-size: 1.25rem;
            font-weight: 600;
        }

        .close-btn {
            background: none;
            border: none;
            font-size: 1.5rem;
            color: #6b7280;
            cursor: pointer;
            padding: 0.25rem;
        }

        .modal-body {
            padding: 1.5rem;
        }

        .form-group {
            margin-bottom: 1rem;
        }

        .form-label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: #374151;
        }

        .form-input {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 1rem;
        }

        .form-select {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 1rem;
            background: white;
        }

        .modal-footer {
            padding: 1.5rem;
            border-top: 1px solid #e5e7eb;
            display: flex;
            justify-content: end;
            gap: 1rem;
        }

        .btn {
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            font-size: 0.875rem;
            font-weight: 600;
            cursor: pointer;
            border: none;
        }

        .btn-primary {
            background: #3b82f6;
            color: white;
        }

        .btn-secondary {
            background: #f3f4f6;
            color: #374151;
        }

        .add-buttons {
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .fab {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            border: none;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: white;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }

        .fab-income {
            background: #10b981;
        }

        .fab-expense {
            background: #ef4444;
        }

        /* Notification Styles */
        .notification {
            position: fixed;
            top: 2rem;
            right: 2rem;
            color: white;
            padding: 1rem 1.5rem;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            z-index: 1001;
            animation: slideInRight 0.3s ease;
        }

        .notification-success {
            background: #10b981;
        }

        .notification-error {
            background: #ef4444;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideIn {
            from { transform: translate(-50%, -60%); opacity: 0; }
            to { transform: translate(-50%, -50%); opacity: 1; }
        }

        @keyframes slideInRight {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }

        @keyframes slideOutRight {
            from { transform: translateX(0); opacity: 1; }
            to { transform: translateX(100%); opacity: 0; }
        }

        @media (max-width: 1200px) {
            .dashboard-grid {
                grid-template-columns: 1fr 1fr;
            }

            .chart-section {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .dashboard-grid {
                grid-template-columns: 1fr 1fr;
            }

            .main-content {
                padding: 1rem;
            }
        }

        @media (max-width: 480px) {
            .dashboard-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<div class="header">
    <h1>Good Morning, <%= loggedInUser.getName() %>!</h1>
    <div class="header-controls">
        <div class="dropdown">
            Daily <i class="fas fa-chevron-down"></i>
        </div>
        <div class="date-picker">
            <i class="fas fa-calendar"></i>
            <%= new java.text.SimpleDateFormat("dd MMMM yyyy").format(new java.util.Date()) %>
        </div>
        <button class="export-btn" onclick="exportPDF()">
            <i class="fas fa-download"></i>
            Export
        </button>
    </div>
</div>

<div class="main-content">
    <div class="dashboard-grid">

        <!-- Monthly Income -->
        <div class="summary-block income">
            <div class="summary-icon income"><i class="fas fa-arrow-down"></i></div>
            <div class="summary-label">Monthly Income</div>
            <div class="summary-amount income-amount">$0.00</div>
            <div class="summary-sub">Current month earnings</div>
        </div>

        <!-- Monthly Expenses -->
        <div class="summary-block expense">
            <div class="summary-icon expense"><i class="fas fa-arrow-up"></i></div>
            <div class="summary-label">Monthly Expenses</div>
            <div class="summary-amount expense-amount">$0.00</div>
            <div class="summary-sub">Current month spending</div>
        </div>

        <!-- Remaining Monthly Balance -->
        <div class="summary-block balance">
            <div class="summary-icon balance"><i class="fas fa-wallet"></i></div>
            <div class="summary-label">Remaining This Month</div>
            <div class="summary-amount monthly-balance">$0.00</div>
            <div class="summary-sub">Income minus expenses</div>
        </div>

        <!-- Overall Account Balance -->
        <div class="summary-block overall">
            <div class="summary-icon overall"><i class="fas fa-chart-line"></i></div>
            <div class="summary-label">Overall Balance</div>
            <div class="summary-amount overall-balance">$0.00</div>
            <div class="summary-sub">All-time net balance</div>
        </div>

    </div>

    <div class="chart-section">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Overview</h3>
                <div style="display: flex; gap: 1rem;">
                    <div class="dropdown">Yearly <i class="fas fa-chevron-down"></i></div>
                    <button class="filter-btn">
                        <i class="fas fa-filter"></i>
                        Filter
                    </button>
                </div>
            </div>

            <div class="chart-container">
                <div class="chart-bar" style="height: 120px;"></div>
                <div class="chart-bar" style="height: 80px;"></div>
                <div class="chart-bar active" style="height: 200px;">
                    <div style="position: absolute; top: -30px; left: 50%; transform: translateX(-50%); background: white; padding: 0.25rem 0.5rem; border-radius: 4px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); font-size: 0.75rem;">
                        <div style="font-weight: 600;">April 2025</div>
                        <div style="color: #10b981;">Income: $894</div>
                        <div style="color: #ea580c;">Expenses: $768</div>
                    </div>
                    <div class="chart-bar-income" style="height: 120px;"></div>
                    <div class="chart-bar-expense" style="height: 80px;"></div>
                </div>
                <div class="chart-bar" style="height: 150px;"></div>
                <div class="chart-bar" style="height: 90px;"></div>
                <div class="chart-bar" style="height: 110px;"></div>
                <div class="chart-bar" style="height: 130px;"></div>
                <div class="chart-bar" style="height: 100px;"></div>
                <div class="chart-bar" style="height: 85px;"></div>
                <div class="chart-bar" style="height: 160px;"></div>
                <div class="chart-bar" style="height: 95px;"></div>
            </div>
            <div class="chart-labels">
                <span>Feb</span>
                <span>Mar</span>
                <span>Apr</span>
                <span>Mei</span>
                <span>Jun</span>
                <span>Jul</span>
                <span>Aug</span>
                <span>Sep</span>
                <span>Oct</span>
                <span>Nov</span>
                <span>Des</span>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h3 class="card-title">All Expenses</h3>
                <button class="card-menu"><i class="fas fa-ellipsis-h"></i></button>
            </div>
            <div style="font-size: 0.75rem; color: #6b7280; margin-bottom: 1rem;">Spending breakdown by category</div>

            <div class="expenses-breakdown">
                <div class="total-expenses">$24,645.00</div>

                <div class="period-tabs">
                    <span class="period-tab">Daily</span>
                    <span class="period-tab">Weekly</span>
                    <span class="period-tab active">Monthly</span>
                </div>

                <div class="period-amounts">
                    <span>Daily</span>
                    <span>Weekly</span>
                    <span>Monthly</span>
                </div>

                <div class="period-values">
                    <span>$1,345</span>
                    <span>$7,136</span>
                    <span>$14,927</span>
                </div>

                <div class="color-bar"></div>

                <ul class="expense-categories">
                    <li class="expense-category">
                        <div class="category-info">
                            <div class="category-dot dot-food"></div>
                            <span>Food &amp; Health</span>
                        </div>
                        <span>863</span>
                    </li>
                    <li class="expense-category">
                        <div class="category-info">
                            <div class="category-dot dot-entertainment"></div>
                            <span>Entertainments</span>
                        </div>
                        <span>248</span>
                    </li>
                    <li class="expense-category">
                        <div class="category-info">
                            <div class="category-dot dot-shopping"></div>
                            <span>Shopping</span>
                        </div>
                        <span>1835</span>
                    </li>
                    <li class="expense-category">
                        <div class="category-info">
                            <div class="category-dot dot-investment"></div>
                            <span>Investment</span>
                        </div>
                        <span>1835</span>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <div class="card transactions-section">
        <div class="card-header">
            <h3 class="card-title">Recent Transactions</h3>
            <div class="filters">
                <button class="filter-btn">
                    <i class="fas fa-sort"></i>
                    Short
                </button>
                <button class="filter-btn">
                    <i class="fas fa-filter"></i>
                    Filter
                </button>
            </div>
        </div>

        <table class="transactions-table">
            <thead>
            <tr>
                <th>Date <i class="fas fa-sort"></i></th>
                <th>Category <i class="fas fa-sort"></i></th>
                <th>Amount <i class="fas fa-sort"></i></th>
                <th>Status</th>
                <th>Action</th>
            </tr>
            </thead>
            <tbody>
            <tr>
                <td>Jan 14, 2025</td>
                <td>Subscription</td>
                <td>$440.00</td>
                <td><span class="status-success">Success</span></td>
                <td><button class="action-btn"><i class="fas fa-ellipsis-h"></i></button></td>
            </tr>
            <tr>
                <td>Jan 10, 2025</td>
                <td>Transfer</td>
                <td>$440.00</td>
                <td><span class="status-success">Success</span></td>
                <td><button class="action-btn"><i class="fas fa-ellipsis-h"></i></button></td>
            </tr>
            <tr>
                <td>Jan 8, 2025</td>
                <td>Transfer</td>
                <td>$440.00</td>
                <td><span class="status-success">Success</span></td>
                <td><button class="action-btn"><i class="fas fa-ellipsis-h"></i></button></td>
            </tr>
            </tbody>
        </table>
    </div>
</div>

<!-- Add Income/Expense Buttons -->
<div class="add-buttons">
    <button class="fab fab-income" onclick="openIncomeModal()" title="Add Income">
        <i class="fas fa-plus"></i>
    </button>
    <button class="fab fab-expense" onclick="openExpenseModal()" title="Add Expense">
        <i class="fas fa-minus"></i>
    </button>
</div>

<!-- Income Modal -->
<div id="incomeModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2 class="modal-title">Add Income</h2>
            <button class="close-btn" onclick="closeModal('incomeModal')">&times;</button>
        </div>
        <div class="modal-body">
            <div class="form-group">
                <label class="form-label">Amount</label>
                <input type="number" class="form-input" id="incomeAmount" placeholder="Enter amount" required>
            </div>
            <div class="form-group">
                <label class="form-label">Category</label>
                <select class="form-select" id="incomeCategory" required>
                    <option value="">Select category</option>
                    <option value="salary">Salary</option>
                    <option value="freelance">Freelance</option>
                    <option value="business">Business</option>
                    <option value="investment">Investment</option>
                    <option value="other">Other</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Description</label>
                <input type="text" class="form-input" id="incomeDescription" placeholder="Enter description">
            </div>
            <div class="form-group">
                <label class="form-label">Date</label>
                <input type="date" class="form-input" id="incomeDate" required>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeModal('incomeModal')">Cancel</button>
            <button class="btn btn-primary" onclick="addIncome()">Add Income</button>
        </div>
    </div>
</div>

<!-- Expense Modal -->
<div id="expenseModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2 class="modal-title">Add Expense</h2>
            <button class="close-btn" onclick="closeModal('expenseModal')">&times;</button>
        </div>
        <div class="modal-body">
            <div class="form-group">
                <label class="form-label">Amount</label>
                <input type="number" class="form-input" id="expenseAmount" placeholder="Enter amount" required>
            </div>
            <div class="form-group">
                <label class="form-label">Category</label>
                <select class="form-select" id="expenseCategory" required>
                    <option value="">Select category</option>
                    <option value="food">Food &amp; Health</option>
                    <option value="entertainment">Entertainment</option>
                    <option value="shopping">Shopping</option>
                    <option value="investment">Investment</option>
                    <option value="transport">Transport</option>
                    <option value="utilities">Utilities</option>
                    <option value="other">Other</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Description</label>
                <input type="text" class="form-input" id="expenseDescription" placeholder="Enter description">
            </div>
            <div class="form-group">
                <label class="form-label">Date</label>
                <input type="date" class="form-input" id="expenseDate" required>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeModal('expenseModal')">Cancel</button>
            <button class="btn btn-primary" onclick="addExpense()">Add Expense</button>
        </div>
    </div>
</div>

<script>
    // Initialize data
    var transactions = [];
    var monthlyIncome = 0;
    var monthlyExpenses = 0;

    var currentFilter = 'monthly';

    // Set today's date as default
    var today = new Date().toISOString().split('T')[0];
    document.getElementById('incomeDate').value = today;
    document.getElementById('expenseDate').value = today;

    // Modal functions
    function openIncomeModal() {
        document.getElementById('incomeModal').style.display = 'block';
        document.body.style.overflow = 'hidden';
    }

    function openExpenseModal() {
        document.getElementById('expenseModal').style.display = 'block';
        document.body.style.overflow = 'hidden';
    }

    function closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
        document.body.style.overflow = 'auto';

        if (modalId === 'incomeModal') {
            document.getElementById('incomeAmount').value = '';
            document.getElementById('incomeCategory').value = '';
            document.getElementById('incomeDescription').value = '';
            document.getElementById('incomeDate').value = today;
        } else {
            document.getElementById('expenseAmount').value = '';
            document.getElementById('expenseCategory').value = '';
            document.getElementById('expenseDescription').value = '';
            document.getElementById('expenseDate').value = today;
        }
    }

    window.onclick = function(event) {
        var incomeModal = document.getElementById('incomeModal');
        var expenseModal = document.getElementById('expenseModal');

        if (event.target === incomeModal) {
            closeModal('incomeModal');
        }

        if (event.target === expenseModal) {
            closeModal('expenseModal');
        }
    }

    // Add income
    function addIncome() {

        var amount = document.getElementById('incomeAmount').value;
        var category = document.getElementById('incomeCategory').value;
        var description = document.getElementById('incomeDescription').value;
        var date = document.getElementById('incomeDate').value;

        fetch('add-transaction', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body:
                'type=income' +
                '&category=' + encodeURIComponent(category) +
                '&amount=' + encodeURIComponent(amount) +
                '&description=' + encodeURIComponent(description) +
                '&date=' + encodeURIComponent(date)
        })
            .then(function(response) {
                return response.text();
            })
            .then(function() {
                alert("Income Added!");
                location.reload();
            })
            .catch(function(error) {
                console.error(error);
            });

        closeModal('incomeModal');
    }

    // Add expense
    function addExpense() {

        var amount = document.getElementById('expenseAmount').value;
        var category = document.getElementById('expenseCategory').value;
        var description = document.getElementById('expenseDescription').value;
        var date = document.getElementById('expenseDate').value;

        fetch('add-transaction', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body:
                'type=expense' +
                '&category=' + encodeURIComponent(category) +
                '&amount=' + encodeURIComponent(amount) +
                '&description=' + encodeURIComponent(description) +
                '&date=' + encodeURIComponent(date)
        })
            .then(function(response) {
                return response.text();
            })
            .then(function() {
                alert("Expense Added!");
                location.reload();
            })
            .catch(function(error) {
                console.error(error);
            });

        closeModal('expenseModal');
    }

    // =========================
    // FILTER FUNCTIONS
    // =========================

    function getFilteredTransactions(filterType) {

        var now = new Date();

        return transactions.filter(function(t) {

            var transactionDate = new Date(t.date);

            if (filterType === 'daily') {

                return transactionDate.toDateString() === now.toDateString();
            }

            if (filterType === 'weekly') {

                var sevenDaysAgo = new Date();
                sevenDaysAgo.setDate(now.getDate() - 7);

                return transactionDate >= sevenDaysAgo;
            }

            if (filterType === 'monthly') {

                return transactionDate.getMonth() === now.getMonth() &&
                    transactionDate.getFullYear() === now.getFullYear();
            }

            return true;
        });
    }

    // =========================
    // UPDATE DASHBOARD
    // =========================

    function updateDashboard() {

        var filtered = getFilteredTransactions(currentFilter);

        var income = 0;
        var expenses = 0;

        filtered.forEach(function(t) {

            if (t.type === 'income') {
                income += t.amount;
            }

            if (t.type === 'expense') {
                expenses += t.amount;
            }
        });

        monthlyIncome = income;
        monthlyExpenses = expenses;

        // Monthly Income
        document.querySelector('.income-amount').textContent =
            '$' + income.toFixed(2);

        // Monthly Expenses
        document.querySelector('.expense-amount').textContent =
            '$' + expenses.toFixed(2);

        // Remaining Monthly Balance
        var monthlyBalance = income - expenses;
        var monthlyBalanceEl = document.querySelector('.monthly-balance');
        monthlyBalanceEl.textContent =
            (monthlyBalance >= 0 ? '+' : '') + '$' + Math.abs(monthlyBalance).toFixed(2);
        monthlyBalanceEl.style.color = monthlyBalance >= 0 ? '#10b981' : '#ef4444';

        // Overall Account Balance (all transactions, not filtered)
        var totalIncome = 0;
        var totalExpenses = 0;
        transactions.forEach(function(t) {
            if (t.type === 'income') totalIncome += t.amount;
            if (t.type === 'expense') totalExpenses += t.amount;
        });
        var overallBalance = totalIncome - totalExpenses;
        var overallBalanceEl = document.querySelector('.overall-balance');
        overallBalanceEl.textContent =
            (overallBalance >= 0 ? '+' : '') + '$' + Math.abs(overallBalance).toFixed(2);
        overallBalanceEl.style.color = overallBalance >= 0 ? '#10b981' : '#ef4444';

        // Total expenses box (All Expenses card)
        document.querySelector('.total-expenses').textContent =
            '$' + expenses.toFixed(2);

        // Daily Weekly Monthly values
        updatePeriodValues();

        // Categories
        updateExpenseCategories(filtered);

        // Chart
        updateChart();

        // Transactions table
        updateTransactionsTable(filtered);
    }

    // =========================
    // PERIOD VALUES
    // =========================

    function updatePeriodValues() {

        var daily = 0;
        var weekly = 0;
        var monthly = 0;

        var dailyTransactions = getFilteredTransactions('daily');
        var weeklyTransactions = getFilteredTransactions('weekly');
        var monthlyTransactions = getFilteredTransactions('monthly');

        dailyTransactions.forEach(function(t) {
            if (t.type === 'expense') {
                daily += t.amount;
            }
        });

        weeklyTransactions.forEach(function(t) {
            if (t.type === 'expense') {
                weekly += t.amount;
            }
        });

        monthlyTransactions.forEach(function(t) {
            if (t.type === 'expense') {
                monthly += t.amount;
            }
        });

        var values = document.querySelectorAll('.period-values span');

        values[0].textContent = '$' + daily.toFixed(2);
        values[1].textContent = '$' + weekly.toFixed(2);
        values[2].textContent = '$' + monthly.toFixed(2);
    }

    // =========================
    // CATEGORY TOTALS
    // =========================

    function updateExpenseCategories(filtered) {

        var categoryTotals = {};

        filtered.forEach(function(t) {

            if (t.type === 'expense') {

                if (!categoryTotals[t.category]) {
                    categoryTotals[t.category] = 0;
                }

                categoryTotals[t.category] += t.amount;
            }
        });

        var list = document.querySelector('.expense-categories');

        list.innerHTML = '';

        for (var category in categoryTotals) {

            var li = document.createElement('li');

            li.className = 'expense-category';

            li.innerHTML =
                '<div class="category-info">' +
                '<div class="category-dot dot-food"></div>' +
                '<span>' + category + '</span>' +
                '</div>' +
                '<span>$' + categoryTotals[category].toFixed(2) + '</span>';

            list.appendChild(li);
        }
    }

    // =========================
    // DYNAMIC CHART
    // =========================

    function updateChart() {

        var chartContainer = document.querySelector('.chart-container');
        var chartLabels = document.querySelector('.chart-labels');

        chartContainer.innerHTML = '';
        chartLabels.innerHTML = '';

        // Always show all 12 months in order
        var allMonths = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

        var currentYear = new Date().getFullYear();

        // Build a data map keyed by month index (0-11)
        var monthlyData = {};
        allMonths.forEach(function(m, i) {
            monthlyData[i] = { income: 0, expense: 0, label: m };
        });

        transactions.forEach(function(t) {
            var d = new Date(t.date);
            if (d.getFullYear() !== currentYear) return; // only current year
            var monthIndex = d.getMonth();

            if (t.type === 'income') {
                monthlyData[monthIndex].income += t.amount;
            }
            if (t.type === 'expense') {
                monthlyData[monthIndex].expense += t.amount;
            }
        });

        // Find max value to normalize heights
        var maxValue = 1;
        for (var i = 0; i < 12; i++) {
            var total = monthlyData[i].income + monthlyData[i].expense;
            if (total > maxValue) maxValue = total;
        }

        var maxBarHeight = 220;

        for (var i = 0; i < 12; i++) {
            var data = monthlyData[i];

            var incomeHeight = (data.income / maxValue) * maxBarHeight;
            var expenseHeight = (data.expense / maxValue) * maxBarHeight;
            var totalHeight = incomeHeight + expenseHeight;

            // Bar
            var bar = document.createElement('div');
            bar.className = totalHeight > 0 ? 'chart-bar active' : 'chart-bar';
            bar.style.height = Math.max(totalHeight, 4) + 'px'; // min 4px so bar is visible
            bar.innerHTML =
                '<div class="chart-bar-income" style="height:' + incomeHeight + 'px;"></div>' +
                '<div class="chart-bar-expense" style="height:' + expenseHeight + 'px;"></div>';
            chartContainer.appendChild(bar);

            // Label
            var label = document.createElement('span');
            label.textContent = data.label;
            chartLabels.appendChild(label);
        }
    }

    // =========================
    // TRANSACTIONS TABLE
    // =========================

    function updateTransactionsTable(filteredTransactions) {

        var tbody =
            document.querySelector('.transactions-table tbody');

        tbody.innerHTML = '';

        filteredTransactions
            .sort(function(a, b) {

                return new Date(b.date) - new Date(a.date);
            })
            .slice(0, 10)
            .forEach(function(transaction) {

                var row = document.createElement('tr');

                var dateObj =
                    new Date(transaction.date);

                var formattedDate =
                    dateObj.toLocaleDateString('en-US', {
                        month: 'short',
                        day: 'numeric',
                        year: 'numeric'
                    });

                var amountColor =
                    transaction.type === 'income'
                        ? '#10b981'
                        : '#ef4444';

                var sign =
                    transaction.type === 'income'
                        ? '+'
                        : '-';

                row.innerHTML =
                    '<td>' + formattedDate + '</td>' +
                    '<td>' + transaction.category + '</td>' +
                    '<td style="color:' + amountColor + '">' +
                    sign + '$' + transaction.amount.toFixed(2) +
                    '</td>' +
                    '<td><span class="status-success">Success</span></td>' +
                    '<td><button class="action-btn"><i class="fas fa-ellipsis-h"></i></button></td>';

                tbody.appendChild(row);
            });
    }

    // =========================
    // FILTER BUTTONS
    // =========================

    document.addEventListener('DOMContentLoaded', function() {

        fetch('dashboard-data')
            .then(function(response) {
                return response.json();
            })
            .then(function(data) {

                transactions = data.transactions;

                updateDashboard();

                var tabs =
                    document.querySelectorAll('.period-tab');

                tabs.forEach(function(tab) {

                    tab.addEventListener('click', function() {

                        tabs.forEach(function(t) {
                            t.classList.remove('active');
                        });

                        this.classList.add('active');

                        currentFilter =
                            this.textContent.toLowerCase();

                        updateDashboard();
                    });
                });
            })
            .catch(function(error) {
                console.error("Error loading dashboard:", error);
            });
    });
    // =========================
    // EXPORT PDF
    // =========================

    function exportPDF() {

        var now = new Date();
        var monthName = now.toLocaleString('default', { month: 'long' });
        var year = now.getFullYear();

        // Get this month's transactions
        var monthlyTransactions = getFilteredTransactions('monthly');

        if (monthlyTransactions.length === 0) {
            alert('No transactions found for this month.');
            return;
        }

        var doc = new jspdf.jsPDF();

        // ---- Header ----
        doc.setFillColor(5, 150, 105); // green
        doc.rect(0, 0, 210, 30, 'F');

        doc.setTextColor(255, 255, 255);
        doc.setFontSize(18);
        doc.setFont('helvetica', 'bold');
        doc.text('Personal Finance Report', 14, 13);

        doc.setFontSize(10);
        doc.setFont('helvetica', 'normal');
        doc.text(monthName + ' ' + year, 14, 22);

        // ---- Summary boxes ----
        var totalIncome = 0;
        var totalExpenses = 0;

        monthlyTransactions.forEach(function(t) {
            if (t.type === 'income') totalIncome += t.amount;
            if (t.type === 'expense') totalExpenses += t.amount;
        });

        var net = totalIncome - totalExpenses;

        doc.setTextColor(30, 41, 59);
        doc.setFontSize(11);
        doc.setFont('helvetica', 'bold');
        doc.text('Summary', 14, 42);

        // Income box
        doc.setFillColor(220, 252, 231);
        doc.roundedRect(14, 46, 55, 20, 3, 3, 'F');
        doc.setTextColor(22, 163, 74);
        doc.setFontSize(8);
        doc.setFont('helvetica', 'normal');
        doc.text('Total Income', 18, 53);
        doc.setFontSize(11);
        doc.setFont('helvetica', 'bold');
        doc.text('$' + totalIncome.toFixed(2), 18, 61);

        // Expense box
        doc.setFillColor(254, 226, 226);
        doc.roundedRect(74, 46, 55, 20, 3, 3, 'F');
        doc.setTextColor(220, 38, 38);
        doc.setFontSize(8);
        doc.setFont('helvetica', 'normal');
        doc.text('Total Expenses', 78, 53);
        doc.setFontSize(11);
        doc.setFont('helvetica', 'bold');
        doc.text('$' + totalExpenses.toFixed(2), 78, 61);

        // Net box
        var netColor = net >= 0 ? [22, 163, 74] : [220, 38, 38];
        var netBg = net >= 0 ? [220, 252, 231] : [254, 226, 226];
        doc.setFillColor(netBg[0], netBg[1], netBg[2]);
        doc.roundedRect(134, 46, 55, 20, 3, 3, 'F');
        doc.setTextColor(netColor[0], netColor[1], netColor[2]);
        doc.setFontSize(8);
        doc.setFont('helvetica', 'normal');
        doc.text('Net Balance', 138, 53);
        doc.setFontSize(11);
        doc.setFont('helvetica', 'bold');
        doc.text((net >= 0 ? '+' : '') + '$' + net.toFixed(2), 138, 61);

        // ---- Transactions Table ----
        doc.setTextColor(30, 41, 59);
        doc.setFontSize(11);
        doc.setFont('helvetica', 'bold');
        doc.text('Transactions', 14, 78);

        // Sort by date descending
        var sorted = monthlyTransactions.slice().sort(function(a, b) {
            return new Date(b.date) - new Date(a.date);
        });

        var tableRows = sorted.map(function(t) {
            var d = new Date(t.date).toLocaleDateString('en-US', {
                month: 'short', day: 'numeric', year: 'numeric'
            });
            var sign = t.type === 'income' ? '+' : '-';
            return [
                d,
                t.category,
                t.type.charAt(0).toUpperCase() + t.type.slice(1),
                sign + '$' + parseFloat(t.amount).toFixed(2),
                'Success'
            ];
        });

        doc.autoTable({
            startY: 82,
            head: [['Date', 'Category', 'Type', 'Amount', 'Status']],
            body: tableRows,
            headStyles: {
                fillColor: [5, 150, 105],
                textColor: 255,
                fontStyle: 'bold',
                fontSize: 9
            },
            bodyStyles: {
                fontSize: 9,
                textColor: [30, 41, 59]
            },
            alternateRowStyles: {
                fillColor: [248, 250, 252]
            },
            columnStyles: {
                3: {
                    fontStyle: 'bold',
                    halign: 'right'
                }
            },
            didParseCell: function(data) {
                if (data.column.index === 3 && data.section === 'body') {
                    var val = data.cell.raw;
                    if (val && val.charAt(0) === '+') {
                        data.cell.styles.textColor = [22, 163, 74];
                    } else {
                        data.cell.styles.textColor = [220, 38, 38];
                    }
                }
            }
        });

        // ---- Footer ----
        var pageCount = doc.internal.getNumberOfPages();
        for (var p = 1; p <= pageCount; p++) {
            doc.setPage(p);
            doc.setFontSize(8);
            doc.setTextColor(156, 163, 175);
            doc.setFont('helvetica', 'normal');
            doc.text(
                'Generated on ' + new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' }),
                14,
                doc.internal.pageSize.height - 10
            );
            doc.text(
                'Page ' + p + ' of ' + pageCount,
                196,
                doc.internal.pageSize.height - 10,
                { align: 'right' }
            );
        }

        // Save
        doc.save('finance-report-' + monthName.toLowerCase() + '-' + year + '.pdf');
    }
</script>
</body>
</html>
