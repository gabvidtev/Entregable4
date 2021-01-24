'use strict';

import { parseHTML } from '../utils/parseHTML.js';
import { departmentsAPI } from '../api/departments.js';

const employeeRenderer = {

    // Converts an employee into a table row
    // and queries the Department API to get the name of their department
    asTableRow: function (employee) {
        let html = `<table><tr>
                        <td>${employee.employeeId}</td>
                        <td>${employee.firstName}</td>
                        <td>${employee.lastName}</td>
                        <td class="dept"></td>
                        <td>${employee.salary} €</td>
                    </tr></table>`;
        let row = parseHTML(html).querySelector("tr");
        findDepartment(row, employee.departmentId);
        return row;
    },

    // Converts an array of employees into a table
    asTable: function (employees) {
        let html = `<table class="table">
                        <thead>
                            <tr>
                                <th scope="col">ID</th>
                                <th scope="col">Name</th>
                                <th scope="col">Surname</th>
                                <th scope="col">Department</th>
                                <th scope="col">Salary</th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>`;
        let table = parseHTML(html);
        let tableBody = table.querySelector("tbody");

        // Fill in the employees
        for (let emp of employees) {
            let row = this.asTableRow(emp);
            tableBody.appendChild(row);
        }

        return table;
    }
};

// Aux function to put a department name and city into a table row
function findDepartment(row, departmentId) {
    let tdDep = row.querySelector("td.dept");
    if (departmentId === null) {
        tdDep.textContent = "-";
    } else {
        departmentsAPI.getById(departmentId)
            .then(dep => {
                let content = `${dep.name} (${dep.city})`;
                tdDep.textContent = content;
            });
    }
}

export { employeeRenderer };