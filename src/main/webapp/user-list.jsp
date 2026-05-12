<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title>User Management</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background-color: #f8fafc;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #1e293b;
        }

        .container {
            background: white;
            border-radius: 24px;
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.1);
            width: 95%;
            max-width: 1200px;
            padding: 40px;
            animation: fadeIn 0.6s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        h1 { text-align: center; margin-bottom: 10px; font-size: 2rem; }

        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 20px 0;
        }

        .btn-add {
            background: #3b82f6;
            color: white;
            padding: 10px 18px;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 600;
            transition: 0.3s;
        }

        .btn-add:hover { background: #2563eb; transform: translateY(-2px); }

        table { width: 100%; border-collapse: collapse; margin-top: 20px; border-radius: 12px; overflow: hidden; }

        th { background: #0f172a; color: white; text-align: left; padding: 14px; font-size: 14px; }

        td { padding: 12px 14px; border-bottom: 1px solid #e2e8f0; vertical-align: middle; }

        tr:hover { background: #f1f5f9; }

        .btn {
            padding: 5px 10px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 12px;
            font-weight: 600;
            margin-right: 4px;
            transition: 0.2s;
            display: inline-block;
            cursor: pointer;
            border: none;
        }

        .btn-edit   { background: #fbbf24; color: #111827; }
        .btn-edit:hover { background: #f59e0b; }

        .btn-delete { background: #ef4444; color: white; }
        .btn-delete:hover { background: #dc2626; }

        .btn-view   { background: #8b5cf6; color: white; }
        .btn-view:hover { background: #7c3aed; }

        .btn-ban    { background: #f97316; color: white; }
        .btn-ban:hover { background: #ea580c; }

        .btn-unban  { background: #10b981; color: white; }
        .btn-unban:hover { background: #059669; }

        .btn-premium { background: #eab308; color: #111; }
        .btn-premium:hover { background: #ca8a04; }

        .btn-reset  { background: #64748b; color: white; }
        .btn-reset:hover { background: #475569; }

        .badge {
            padding: 3px 8px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            margin-left: 4px;
        }

        .badge-banned  { background: #fee2e2; color: #dc2626; }
        .badge-premium { background: #fef9c3; color: #92400e; }

        /* Reset password modal */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }

        .modal-overlay.active { display: flex; }

        .modal {
            background: white;
            border-radius: 16px;
            padding: 30px;
            width: 380px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
        }

        .modal h3 { margin-bottom: 16px; font-size: 1.2rem; }

        .modal input {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #d1d5db;
            border-radius: 10px;
            font-size: 14px;
            margin-bottom: 16px;
        }

        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; }

        .btn-confirm { background: #3b82f6; color: white; padding: 8px 16px; border-radius: 10px; border: none; cursor: pointer; font-weight: 600; }
        .btn-cancel  { background: #f1f5f9; color: #374151; padding: 8px 16px; border-radius: 10px; border: none; cursor: pointer; font-weight: 600; }

        /* Back to admin button (shown when impersonating) */
        .impersonate-bar {
            background: #7c3aed;
            color: white;
            text-align: center;
            padding: 10px;
            font-size: 14px;
            font-weight: 600;
        }
    </style>
</head>
<body>

<!-- Reset Password Modal -->
<div class="modal-overlay" id="resetModal">
    <div class="modal">
        <h3>Reset Password</h3>
        <input type="password" id="newPasswordInput" placeholder="Enter new password" />
        <div class="modal-actions">
            <button class="btn-cancel" onclick="closeResetModal()">Cancel</button>
            <button class="btn-confirm" onclick="submitReset()">Reset</button>
        </div>
    </div>
</div>

<div class="container">
    <h1>User Management System</h1>

    <div class="top-bar">
        <h3>All Users (<c:out value="${listUser.size()}"/> registered)</h3>
        <a class="btn-add" href="users?action=new">+ Add User</a>
    </div>

    <table>
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Email</th>
            <th>Country</th>
            <th>Status</th>
            <th>Actions</th>
        </tr>

        <c:forEach var="user" items="${listUser}">
            <tr>
                <td>${user.id}</td>
                <td>
                        ${user.name}
                    <c:if test="${user.banned}">
                        <span class="badge badge-banned">Banned</span>
                    </c:if>
                    <c:if test="${user.premium}">
                        <span class="badge badge-premium">⭐ Premium</span>
                    </c:if>
                </td>
                <td>${user.email}</td>
                <td>${user.country}</td>
                <td>
                    <c:choose>
                        <c:when test="${user.banned}">🔴 Banned</c:when>
                        <c:when test="${user.premium}">⭐ Premium</c:when>
                        <c:otherwise>✅ Active</c:otherwise>
                    </c:choose>
                </td>
                <td>
                    <!-- Edit -->
                    <a class="btn btn-edit" href="users?action=edit&id=${user.id}">Edit</a>

                    <!-- Delete -->
                    <a class="btn btn-delete"
                       href="users?action=delete&id=${user.id}"
                       onclick="return confirm('Delete this user?')">Delete</a>

                    <!-- View as User -->
                    <a class="btn btn-view"
                       href="users?action=viewAsUser&id=${user.id}"
                       onclick="return confirm('Switch to this user\'s view?')">👁 View As</a>

                    <!-- Ban / Unban -->
                    <c:choose>
                        <c:when test="${user.banned}">
                            <a class="btn btn-unban"
                               href="users?action=ban&id=${user.id}">Unban</a>
                        </c:when>
                        <c:otherwise>
                            <a class="btn btn-ban"
                               href="users?action=ban&id=${user.id}"
                               onclick="return confirm('Ban this user?')">Ban</a>
                        </c:otherwise>
                    </c:choose>

                    <!-- Reset Password -->
                    <button class="btn btn-reset"
                            onclick="openResetModal(${user.id})">Reset Pwd</button>

                    <!-- Toggle Premium -->
                    <c:choose>
                        <c:when test="${user.premium}">
                            <a class="btn btn-premium"
                               href="users?action=togglePremium&id=${user.id}">Remove ⭐</a>
                        </c:when>
                        <c:otherwise>
                            <a class="btn btn-premium"
                               href="users?action=togglePremium&id=${user.id}">Add ⭐</a>
                        </c:otherwise>
                    </c:choose>
                </td>
            </tr>
        </c:forEach>
    </table>
</div>

<script>
    var resetUserId = null;

    function openResetModal(userId) {
        resetUserId = userId;
        document.getElementById('newPasswordInput').value = '';
        document.getElementById('resetModal').classList.add('active');
    }

    function closeResetModal() {
        document.getElementById('resetModal').classList.remove('active');
        resetUserId = null;
    }

    function submitReset() {
        var newPassword = document.getElementById('newPasswordInput').value;
        if (!newPassword || newPassword.length < 4) {
            alert('Password must be at least 4 characters.');
            return;
        }
        window.location.href = 'users?action=resetPassword&id=' + resetUserId + '&newPassword=' + encodeURIComponent(newPassword);
    }

    // Close modal on overlay click
    document.getElementById('resetModal').addEventListener('click', function(e) {
        if (e.target === this) closeResetModal();
    });
</script>

</body>
</html>