'use strict';

import { sessionManager } from './utils/session.js';

import { employeesAPI } from '/js/api/employees.js';
import { departmentsAPI } from '/js/api/departments.js';

import { employeeRenderer } from '/js/renderers/employees.js';
import { departmentRenderer } from '/js/renderers/departments.js';
import { messageRenderer } from '/js/renderers/messages.js';

// DOM elements that we will use
const employeesCont = document.getElementById("employees");
const departmentsCont = document.getElementById("departments");
const newDpmtButton = document.getElementById("new-dpmt-button");

// Main function that will run when the page is ready
function main() {
    // Hide the options that shouldnt be available for not logged users
    setLoggedOptions();

    // Load the employees
    employeesAPI.getAll()
        .then(employees => {
            let table = employeeRenderer.asTable(employees);
            employeesCont.appendChild(table);
        })
        .catch(error => messageRenderer.showErrorAsAlert(error));
    
    // Load the departments
    departmentsAPI.getAll()
        .then(departments => {
            let badgeGroup = departmentRenderer.asBadgeGroup(departments);
            departmentsCont.appendChild(badgeGroup);
        })
        .catch(error => messageRenderer.showErrorAsAlert(error));
}

document.addEventListener("DOMContentLoaded", function () {
    main();
});

///////////

function setLoggedOptions() {
    // Hide the things that shouldnt be available for non authenticated users
    if (!sessionManager.isLogged()) {
        newDpmtButton.style.display = "none";
    }
}