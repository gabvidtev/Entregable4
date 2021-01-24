'use_strict';

import { BASE_URL, requestOptions } from './common.js';

const employeesAPI = {

    getAll: function () {
        return new Promise(function (resolve, reject) {
            axios
                .get(`${BASE_URL}/employees`, requestOptions)
                .then(response => resolve(response.data))
                .catch(error => reject(error.response.data.message));
        });
    },
};

export { employeesAPI };