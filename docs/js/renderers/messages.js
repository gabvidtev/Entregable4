'use strict';

import { parseHTML } from '../utils/parseHTML.js';

// Aux function to get the div in which to display messages
// It's centralized here so we can change it easily in the case its ID changes
function getErrorsDiv() {
    return document.getElementById("errors");
}

const messageRenderer = {

    showMessageAsAlert: function (message, bootClass) {
        let html = `<div class="alert alert-${bootClass} alert-dismissible col-md-12">
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                        ${message}
                    </div>`;
        let errorsDiv = getErrorsDiv();
        let messageElem = parseHTML(html);
        errorsDiv.appendChild(messageElem);
    },

    showErrorAsAlert: function (message) {
        this.showMessageAsAlert(message, "danger");
    },

    showWarningAsAlert: function (message) {
        this.showMessageAsAlert(message, "warning");
    },

    showSuccessAsAlert: function (message) {
        this.showMessageAsAlert(message, "success");
    },
}

export { messageRenderer };