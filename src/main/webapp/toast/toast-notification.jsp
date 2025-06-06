
<div id="foodmartToastContainer"></div>

<style>
    #foodmartToastContainer {
        position: fixed;
        top: 75px; /* Adjusted to be below a potentially sticky header */
        right: 20px;
        z-index: 9999;
        display: flex;
        flex-direction: column;
        align-items: flex-end;
        gap: 10px; /* Spacing between toasts */
    }

    .fm-toast {
        background-color: #333; /* Default background */
        color: #fff;
        padding: 14px 20px; /* Slightly adjusted padding */
        border-radius: 8px;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        opacity: 0;
        transform: translateX(110%); /* Start off-screen (right) */
        transition: opacity 0.4s ease-in-out, transform 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        display: flex;
        justify-content: space-between;
        align-items: center;
        min-width: 280px; /* Min width */
        max-width: 380px; /* Max width */
        font-family: 'Open Sans', sans-serif; /* Consistent font */
        font-size: 0.95rem;
    }

    .fm-toast.show {
        opacity: 1;
        transform: translateX(0);
    }

    .fm-toast-message {
        flex-grow: 1;
        padding-right: 10px; /* Space before close button */
    }

    .fm-toast-icon {
        margin-right: 10px;
        font-size: 1.2em; /* Icon size */
    }

    .fm-toast-close-button {
        background: none;
        border: none;
        color: inherit; /* Inherit color from toast type */
        font-size: 1.4em;
        font-weight: bold;
        cursor: pointer;
        padding: 0 5px;
        opacity: 0.7;
        transition: opacity 0.2s ease;
    }

    .fm-toast-close-button:hover {
        opacity: 1;
    }

    /* Toast Types */
    .fm-toast.success {
        background-color: #4CAF50; /* Green */
        color: #fff;
    }

    .fm-toast.error {
        background-color: #f44336; /* Red */
        color: #fff;
    }

    .fm-toast.info {
        background-color: #2196F3; /* Blue */
        color: #fff;
    }

    .fm-toast.warning {
        background-color: #ff9800; /* Orange */
        color: #fff;
    }

   
</style>

<script>
    function showFoodMartToast(message, type = 'info', duration = 5000) {
        const container = document.getElementById('foodmartToastContainer');
        if (!container) {
            console.error('FoodMart Toast container not found!');
            return;
        }

        const toast = document.createElement('div');
        toast.className = `fm-toast ${type.toLowerCase()}`; // e.g., fm-toast success

        // Icon based on type
        const iconElement = document.createElement('span');
        iconElement.className = 'fm-toast-icon';
        let iconClass = 'fas fa-info-circle'; // Default icon
        if (type.toLowerCase() === 'success') iconClass = 'fas fa-check-circle';
        else if (type.toLowerCase() === 'error') iconClass = 'fas fa-exclamation-circle';
        else if (type.toLowerCase() === 'warning') iconClass = 'fas fa-exclamation-triangle';
        iconElement.innerHTML = `<i class="${iconClass}"></i>`;
        toast.appendChild(iconElement);

        const messageElement = document.createElement('span');
        messageElement.className = 'fm-toast-message';
        messageElement.textContent = message;
        toast.appendChild(messageElement);

        const closeButton = document.createElement('button');
        closeButton.className = 'fm-toast-close-button';
        closeButton.innerHTML = '&times;'; // 'x' character
        
        const closeAction = () => {
            toast.classList.remove('show');
            // Remove the toast from DOM after animation
            toast.addEventListener('transitionend', () => {
                if (toast.parentNode === container) {
                    container.removeChild(toast);
                }
            }, { once: true }); // Ensure event listener is removed after execution
        };
        closeButton.onclick = closeAction;
        toast.appendChild(closeButton);

        container.appendChild(toast);

        // Trigger the show animation
        requestAnimationFrame(() => { // Ensures element is in DOM before class change
            requestAnimationFrame(() => {
                 toast.classList.add('show');
            });
        });
       

        // Auto-dismiss
        if (duration > 0) {
            setTimeout(() => {
                if (toast.classList.contains('show')) { // Check if not manually closed
                    closeAction();
                }
            }, duration);
        }
    }

 
    // Function to display toast messages from session/request attributes
    function displaySessionToast() {
        <%
            String toastMessage = (String) session.getAttribute("toastMessage");
            String toastType = (String) session.getAttribute("toastType");

            if (toastMessage != null && !toastMessage.isEmpty()) {
        %>
            showFoodMartToast("<%= toastMessage.replace("\"", "\\\"").replace("'", "\\'").replace("\n", "\\n").replace("\r", "\\r") %>", "<%= toastType != null ? toastType : "info" %>");
        <%
                session.removeAttribute("toastMessage");
                session.removeAttribute("toastType");
            }

            // Check for request attributes as well (for non-redirect scenarios)
            String requestToastMessage = (String) request.getAttribute("toastMessage");
            String requestToastType = (String) request.getAttribute("toastType");
            if (requestToastMessage != null && !requestToastMessage.isEmpty()) {
        %>
            showFoodMartToast("<%= requestToastMessage.replace("\"", "\\\"").replace("'", "\\'").replace("\n", "\\n").replace("\r", "\\r") %>", "<%= requestToastType != null ? requestToastType : "info" %>");
        <%
            }
        %>
    }

    // Display toast when the DOM is fully loaded
    document.addEventListener('DOMContentLoaded', displaySessionToast);
</script>
