
$(document).ready(function() {
	$('#calendar').calendar({
        dataSource: [ {
  name : "Tagebuch von Schnitzler, 27. 4. 1891",
  startDate : new Date(1891,00,1),
  endDate : new Date(1891,0,1)
}, {
  name : "Tagebuch von Schnitzler, 28. 4. 1891",
  startDate : new Date(1891,03,28),
  endDate : new Date(1891,03,28)
}, {
  "name" : "E. M. Kafka an Bahr, 12. 8. 1891",
  "startDate" : new Date(1891,07,12),
  "endDate" : new Date(1891,07,12),
  "id" : "L041646"
  
}
],
        startYear: 1891,
        disabledDays: [
            new Date(1891,0,2),
            new Date(1891,0,3),
            new Date(1891,0,8)
        ]
    });
});
