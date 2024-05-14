# Use the official Nginx base image
FROM nginx:alpine

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Create the /etc/nginx/templates directory
RUN mkdir -p /etc/nginx/templates

# Create a new Nginx configuration file using heredoc syntax
RUN cat <<EOF > /etc/nginx/templates/default.conf.template
server {
    listen \${PORT};
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
EOF

# Create the HTML file with React app and Tailwind configuration
RUN cat <<-'EOF' > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calendar Booking App</title>
    <script src="https://unpkg.com/react/umd/react.development.js"></script>
    <script src="https://unpkg.com/react-dom/umd/react-dom.development.js"></script>
    <script src="https://unpkg.com/@babel/standalone/babel.js"></script>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css"></link>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
        }
    </style>
</head>
<body class="bg-gray-100 text-gray-800">
    <div id="root" class="min-h-screen flex justify-center items-center"></div>
    <script type="text/babel">
        // CalendarBookingApp Component
        const CalendarBookingApp = () => {
            const [selectedDate, setSelectedDate] = React.useState("");
            const handleDateChange = (event) => setSelectedDate(event.target.value);
            return (
                <div className="max-w-lg mx-auto bg-white p-6 rounded-lg shadow-lg">
                    <h1 className="text-2xl font-bold mb-4">Calendar Booking App</h1>
                    <div className="mb-4">
                        <label htmlFor="date" className="block text-gray-700">Select a Date:</label>
                        <input
                            type="date"
                            id="date"
                            className="mt-1 block w-full p-2 border border-gray-300 rounded-md"
                            value={selectedDate}
                            onChange={handleDateChange}
                        />
                    </div>
                    <div className="mb-4">
                        <label htmlFor="time" className="block text-gray-700">Select a Time:</label>
                        <input
                            type="time"
                            id="time"
                            className="mt-1 block w-full p-2 border border-gray-300 rounded-md"
                        />
                    </div>
                    <button className="w-full py-2 bg-blue-500 text-white font-bold rounded-lg hover:bg-blue-600">
                        Book Appointment
                    </button>
                </div>
            );
        };

        // Render component to the root
        ReactDOM.render(<CalendarBookingApp />, document.getElementById('root'));
    </script>
</body>
</html>
EOF

# Set environment variable for PORT
ENV PORT=80

# Add entrypoint with dynamic environment substitution
CMD sh -c "envsubst '\${PORT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"