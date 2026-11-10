export const generateUniqueId = () => {
    return `id_${Math.random().toString(36).substr(2, 9)}`;
};

export const formatTimestamp = (timestamp) => {
    const date = new Date(timestamp);
    return date.toLocaleString();
};

export const validateInput = (input) => {
    return input && input.trim().length > 0;
};

export const debounce = (func, delay) => {
    let timeoutId;
    return (...args) => {
        if (timeoutId) {
            clearTimeout(timeoutId);
        }
        timeoutId = setTimeout(() => {
            func.apply(null, args);
        }, delay);
    };
};