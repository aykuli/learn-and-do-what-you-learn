FROM nginx:1.29.0
COPY ./index.html /usr/share/nginx/html/index.html

EXPOSE 80
RUN echo "Aynur's custom nginx image"

CMD ["nginx", "-g", "daemon off;"]