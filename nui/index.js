const toastContainer = document.getElementById('toast-container');
const showToastButton = document.getElementById('showToast');

function createToast(message, type = 'info', duration = 5000) {
  console.log('Creating toast');

  const iconColor =
    type === 'success'
      ? 'text-green-400'
      : type === 'error'
      ? 'text-red-400'
      : type === 'warn'
      ? 'text-yellow-400'
      : 'text-blue-400'; // Default gray for general notifications

  const iconClass =
    type === 'success'
      ? 'fas fa-check-circle'
      : type === 'error'
      ? 'fas fa-times-circle'
      : type === 'warn'
      ? 'fas fa-exclamation-circle'
      : 'fas fa-info-circle'; // Default icon for general notifications

  const bgClass =
    type === 'success'
      ? 'toast-success'
      : type === 'error'
      ? 'toast-error'
      : type === 'warn'
      ? 'toast-warn'
      : 'toast-info'; // Default icon for general notifications

  const toast = document.createElement('div');
  toast.className = `toast relative flex items-center p-4 rounded-md shadow-lg bg-gray-900 text-white min-w-[250px] max-w-xs overflow-hidden ${bgClass}`;

  toast.innerHTML = `
    <div class="flex-shrink-0 w-10 h-10 rounded-full flex items-center justify-center bg-opacity-30 text-2xl ${iconColor}">
      <i class="${iconClass}"></i>
    </div>
    <div class="flex-1 text-sm break-words ml-4">${message}</div>
    <div class="toast-progress-bar absolute bottom-0 left-0 h-1 rounded-md bg-${type === 'success' ? 'green' : type === 'error' ? 'red' : type === 'warn' ? 'yellow' : 'blue'}-400"></div>
  `;

  // Append the toast to the container
  toastContainer.appendChild(toast);

  // Set the progress bar width
  const progressBar = toast.querySelector('.toast-progress-bar');
  progressBar.style.width = '100%';

  // Animate the progress bar
  setTimeout(() => {
    progressBar.style.transition = `width linear ${duration}ms`;
    progressBar.style.width = '0%';
  }, 10);

  // Remove the toast after the specified duration
  setTimeout(() => {
    toast.remove();
  }, duration);
}

showToastButton.addEventListener('click', () => {
  createToast('Success! Operation completed successfully.', 'success');
  createToast(
    'Warning! Check your inputs. This is a longer message with more text.',
    'warn'
  );
  createToast('Error! Something went wrong.', 'error');
  createToast('General notification with default settings.', '');
});

window.addEventListener('message', function (data) {
  data = data.data;

  if (data.action === 'FS-Lib:notify') {
    console.log('Trying to create toast');
    createToast(data.msg, data.type, data.duration);
  }
});