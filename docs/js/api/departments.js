'use_strict';

import { BASE_URL, requestOptions } from './common.js';

const departmentsAPI = {

    getAll: function () {
        return new Promise(function (resolve, reject) {
            axios
                .get(`${BASE_URL}/departments`, requestOptions)
                .then(response => resolve(response.data))
                .catch(error => reject(error.response.data.message));
        });
    },

    getById: function (departmentId) {
        return new Promise(function (resolve, reject) {
            axios
                .get(`${BASE_URL}/departments/${departmentId}`, requestOptions)
                .then(response => resolve(response.data[0]))
                .catch(error => reject(error.response.data.message));
        });
    },

    create: function (formData) {
        return new Promise(function (resolve, reject) {
            axios
                .post(`${BASE_URL}/departments`, formData, requestOptions)
                .then(response => resolve(response.data))
                .catch(error => reject(error.response.data.message));
        });
    },
};

export { departmentsAPI };