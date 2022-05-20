<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ config('app.name','Andrea Maurice') }}</title>
    <link rel="preconnect" href="https://fonts.gstatic.com">
    <link href="https://fonts.googleapis.com/css2?family=Poppins&family=Sora:wght@700&display=swap" rel="stylesheet">
    <style>
        body{
        font-family: 'Poppins', sans-serif;
        margin: 0px;
        }
        h1, h2, h3, h4{
        font-family: 'Sora', sans-serif;
        }
        h1{
            font-size: 80px;
        }
        .row{
            margin-inline: 200px;
            margin-top: 130px;
            text-align: center;
            padding-inline: 0px;
        }
        a{
            text-decoration: none;
            color: black;
        }
        a:hover{
            color: blue;
        }
        p{
            color: gray;
        }
        /* Floating Particles from CodePen: still modified though HAHA*/
        .particle, .particle-circle {
        position: absolute;
        z-index: -99999;
        top: 0;
            left: 0;
        }

        .particle-circle{
            border-radius: 50%;
        }
        @-webkit-keyframes particle-animation-1 {
        100% {
            transform: translate3d(87vw, 70vh, 97px);
        }
        }

        @keyframes particle-animation-1 {
        100% {
            transform: translate3d(87vw, 70vh, 97px);
        }
        }
        .particle-circle:nth-child(1) {
        -webkit-animation: particle-animation-1 60s infinite;
                animation: particle-animation-1 60s infinite;
        opacity: 0.77;
        height: 13px;
        width: 13px;
        -webkit-animation-delay: -0.2s;
                animation-delay: -0.2s;
        transform: translate3d(66vw, 86vh, 78px);
        background: #8026d9;
        }

        @-webkit-keyframes particle-animation-2 {
        100% {
            transform: translate3d(48vw, 67vh, 12px);
        }
        }

        @keyframes particle-animation-2 {
        100% {
            transform: translate3d(48vw, 67vh, 12px);
        }
        }
        .particle-circle:nth-child(2) {
        -webkit-animation: particle-animation-2 60s infinite;
                animation: particle-animation-2 60s infinite;
        opacity: 0.27;
        height: 12px;
        width: 12px;
        -webkit-animation-delay: -0.4s;
                animation-delay: -0.4s;
        transform: translate3d(47vw, 15vh, 86px);
        background: #26d977;
        }

        @-webkit-keyframes particle-animation-3 {
        100% {
            transform: translate3d(11vw, 8vh, 2px);
        }
        }

        @keyframes particle-animation-3 {
        100% {
            transform: translate3d(11vw, 8vh, 2px);
        }
        }
        .particle-circle:nth-child(3) {
        -webkit-animation: particle-animation-3 60s infinite;
                animation: particle-animation-3 60s infinite;
        opacity: 0.22;
        height: 9px;
        width: 9px;
        -webkit-animation-delay: -0.6s;
                animation-delay: -0.6s;
        transform: translate3d(90vw, 9vh, 45px);
        background: #d93b26;
        }

        @-webkit-keyframes particle-animation-4 {
        100% {
            transform: translate3d(88vw, 28vh, 29px);
        }
        }

        @keyframes particle-animation-4 {
        100% {
            transform: translate3d(88vw, 28vh, 29px);
        }
        }
        .particle-circle:nth-child(4) {
        -webkit-animation: particle-animation-4 60s infinite;
                animation: particle-animation-4 60s infinite;
        opacity: 0.65;
        height: 6px;
        width: 6px;
        -webkit-animation-delay: -0.8s;
                animation-delay: -0.8s;
        transform: translate3d(72vw, 73vh, 9px);
        background: #26afd9;
        }

        @-webkit-keyframes particle-animation-5 {
        100% {
            transform: translate3d(69vw, 67vh, 31px);
        }
        }

        @keyframes particle-animation-5 {
        100% {
            transform: translate3d(69vw, 67vh, 31px);
        }
        }
        .particle-circle:nth-child(5) {
        -webkit-animation: particle-animation-5 60s infinite;
                animation: particle-animation-5 60s infinite;
        opacity: 0.87;
        height: 8px;
        width: 8px;
        -webkit-animation-delay: -1s;
                animation-delay: -1s;
        transform: translate3d(29vw, 15vh, 87px);
        background: #9dd926;
        }

        @-webkit-keyframes particle-animation-6 {
        100% {
            transform: translate3d(49vw, 29vh, 8px);
        }
        }

        @keyframes particle-animation-6 {
        100% {
            transform: translate3d(49vw, 29vh, 8px);
        }
        }
        .particle-circle:nth-child(6) {
        -webkit-animation: particle-animation-6 60s infinite;
                animation: particle-animation-6 60s infinite;
        opacity: 0.4;
        height: 8px;
        width: 8px;
        -webkit-animation-delay: -1.2s;
                animation-delay: -1.2s;
        transform: translate3d(30vw, 17vh, 49px);
        background: #26d997;
        }

        @-webkit-keyframes particle-animation-7 {
        100% {
            transform: translate3d(68vw, 32vh, 74px);
        }
        }

        @keyframes particle-animation-7 {
        100% {
            transform: translate3d(68vw, 32vh, 74px);
        }
        }
        .particle-circle:nth-child(7) {
        -webkit-animation: particle-animation-7 60s infinite;
                animation: particle-animation-7 60s infinite;
        opacity: 0.89;
        height: 10px;
        width: 10px;
        -webkit-animation-delay: -1.4s;
                animation-delay: -1.4s;
        transform: translate3d(78vw, 65vh, 15px);
        background: #be26d9;
        }

        @-webkit-keyframes particle-animation-8 {
        100% {
            transform: translate3d(48vw, 57vh, 69px);
        }
        }

        @keyframes particle-animation-8 {
        100% {
            transform: translate3d(48vw, 57vh, 69px);
        }
        }
        .particle-circle:nth-child(8) {
        -webkit-animation: particle-animation-8 60s infinite;
                animation: particle-animation-8 60s infinite;
        opacity: 0.08;
        height: 7px;
        width: 7px;
        -webkit-animation-delay: -1.6s;
                animation-delay: -1.6s;
        transform: translate3d(17vw, 49vh, 20px);
        background: #3ed926;
        }

        @-webkit-keyframes particle-animation-9 {
        100% {
            transform: translate3d(27vw, 83vh, 5px);
        }
        }

        @keyframes particle-animation-9 {
        100% {
            transform: translate3d(27vw, 83vh, 5px);
        }
        }
        .particle-circle:nth-child(9) {
        -webkit-animation: particle-animation-9 60s infinite;
                animation: particle-animation-9 60s infinite;
        opacity: 0.1;
        height: 8px;
        width: 8px;
        -webkit-animation-delay: -1.8s;
                animation-delay: -1.8s;
        transform: translate3d(24vw, 62vh, 51px);
        background: #d626d9;
        }

        @-webkit-keyframes particle-animation-10 {
        100% {
            transform: translate3d(84vw, 6vh, 3px);
        }
        }

        @keyframes particle-animation-10 {
        100% {
            transform: translate3d(84vw, 6vh, 3px);
        }
        }
        .particle-circle:nth-child(10) {
        -webkit-animation: particle-animation-10 60s infinite;
                animation: particle-animation-10 60s infinite;
        opacity: 0.87;
        height: 7px;
        width: 7px;
        -webkit-animation-delay: -2s;
                animation-delay: -2s;
        transform: translate3d(78vw, 53vh, 99px);
        background: #26d968;
        }

        @-webkit-keyframes particle-animation-11 {
        100% {
            transform: translate3d(71vw, 77vh, 92px);
        }
        }

        @keyframes particle-animation-11 {
        100% {
            transform: translate3d(71vw, 77vh, 92px);
        }
        }
        .particle-circle:nth-child(11) {
        -webkit-animation: particle-animation-11 60s infinite;
                animation: particle-animation-11 60s infinite;
        opacity: 0.1;
        height: 8px;
        width: 8px;
        -webkit-animation-delay: -2.2s;
                animation-delay: -2.2s;
        transform: translate3d(71vw, 9vh, 62px);
        background: #b526d9;
        }

        @-webkit-keyframes particle-animation-12 {
        100% {
            transform: translate3d(71vw, 24vh, 22px);
        }
        }

        @keyframes particle-animation-12 {
        100% {
            transform: translate3d(71vw, 24vh, 22px);
        }
        }
        .particle-circle:nth-child(12) {
        -webkit-animation: particle-animation-12 60s infinite;
                animation: particle-animation-12 60s infinite;
        opacity: 0.31;
        height: 7px;
        width: 7px;
        -webkit-animation-delay: -2.4s;
                animation-delay: -2.4s;
        transform: translate3d(28vw, 45vh, 55px);
        background: #263ed9;
        }

        @-webkit-keyframes particle-animation-13 {
        100% {
            transform: translate3d(69vw, 81vh, 77px);
        }
        }

        @keyframes particle-animation-13 {
        100% {
            transform: translate3d(69vw, 81vh, 77px);
        }
        }
        .particle-circle:nth-child(13) {
        -webkit-animation: particle-animation-13 60s infinite;
                animation: particle-animation-13 60s infinite;
        opacity: 0.05;
        height: 7px;
        width: 7px;
        -webkit-animation-delay: -2.6s;
                animation-delay: -2.6s;
        transform: translate3d(41vw, 12vh, 86px);
        background: #26d988;
        }

        @-webkit-keyframes particle-animation-14 {
        100% {
            transform: translate3d(68vw, 16vh, 36px);
        }
        }

        @keyframes particle-animation-14 {
        100% {
            transform: translate3d(68vw, 16vh, 36px);
        }
        }
        .particle-circle:nth-child(14) {
        -webkit-animation: particle-animation-14 60s infinite;
                animation: particle-animation-14 60s infinite;
        opacity: 0.85;
        height: 9px;
        width: 9px;
        -webkit-animation-delay: -2.8s;
                animation-delay: -2.8s;
        transform: translate3d(27vw, 31vh, 90px);
        background: #d93526;
        }

        @-webkit-keyframes particle-animation-15 {
        100% {
            transform: translate3d(20vw, 39vh, 1px);
        }
        }

        @keyframes particle-animation-15 {
        100% {
            transform: translate3d(20vw, 39vh, 1px);
        }
        }
        .particle-circle:nth-child(15) {
        -webkit-animation: particle-animation-15 60s infinite;
                animation: particle-animation-15 60s infinite;
        opacity: 0.31;
        height: 10px;
        width: 10px;
        -webkit-animation-delay: -3s;
                animation-delay: -3s;
        transform: translate3d(71vw, 80vh, 19px);
        background: #3826d9;
        }

        @-webkit-keyframes particle-animation-16 {
        100% {
            transform: translate3d(79vw, 45vh, 10px);
        }
        }

        @keyframes particle-animation-16 {
        100% {
            transform: translate3d(79vw, 45vh, 10px);
        }
        }
        .particle:nth-child(16) {
        -webkit-animation: particle-animation-16 60s infinite;
                animation: particle-animation-16 60s infinite;
        opacity: 0.35;
        height: 9px;
        width: 9px;
        -webkit-animation-delay: -3.2s;
                animation-delay: -3.2s;
        transform: translate3d(61vw, 62vh, 1px);
        background: #d9d326;
        }

        @-webkit-keyframes particle-animation-17 {
        100% {
            transform: translate3d(49vw, 61vh, 85px);
        }
        }

        @keyframes particle-animation-17 {
        100% {
            transform: translate3d(49vw, 61vh, 85px);
        }
        }
        .particle:nth-child(17) {
        -webkit-animation: particle-animation-17 60s infinite;
                animation: particle-animation-17 60s infinite;
        opacity: 0.89;
        height: 6px;
        width: 6px;
        -webkit-animation-delay: -3.4s;
                animation-delay: -3.4s;
        transform: translate3d(53vw, 81vh, 77px);
        background: #74d926;
        }

        @-webkit-keyframes particle-animation-18 {
        100% {
            transform: translate3d(55vw, 63vh, 90px);
        }
        }

        @keyframes particle-animation-18 {
        100% {
            transform: translate3d(55vw, 63vh, 90px);
        }
        }
        .particle:nth-child(18) {
        -webkit-animation: particle-animation-18 60s infinite;
                animation: particle-animation-18 60s infinite;
        opacity: 0.28;
        height: 6px;
        width: 6px;
        -webkit-animation-delay: -3.6s;
                animation-delay: -3.6s;
        transform: translate3d(54vw, 35vh, 69px);
        background: #269dd9;
        }

        @-webkit-keyframes particle-animation-19 {
        100% {
            transform: translate3d(64vw, 81vh, 97px);
        }
        }

        @keyframes particle-animation-19 {
        100% {
            transform: translate3d(64vw, 81vh, 97px);
        }
        }
        .particle:nth-child(19) {
        -webkit-animation: particle-animation-19 60s infinite;
                animation: particle-animation-19 60s infinite;
        opacity: 0.21;
        height: 10px;
        width: 10px;
        -webkit-animation-delay: -3.8s;
                animation-delay: -3.8s;
        transform: translate3d(9vw, 81vh, 51px);
        background: #2653d9;
        }

        @-webkit-keyframes particle-animation-20 {
        100% {
            transform: translate3d(30vw, 21vh, 74px);
        }
        }

        @keyframes particle-animation-20 {
        100% {
            transform: translate3d(30vw, 21vh, 74px);
        }
        }
        .particle:nth-child(20) {
        -webkit-animation: particle-animation-20 60s infinite;
                animation: particle-animation-20 60s infinite;
        opacity: 0.78;
        height: 9px;
        width: 9px;
        -webkit-animation-delay: -4s;
                animation-delay: -4s;
        transform: translate3d(30vw, 43vh, 28px);
        background: #2677d9;
        }

        @-webkit-keyframes particle-animation-21 {
        100% {
            transform: translate3d(48vw, 66vh, 35px);
        }
        }

        @keyframes particle-animation-21 {
        100% {
            transform: translate3d(48vw, 66vh, 35px);
        }
        }
        .particle:nth-child(21) {
        -webkit-animation: particle-animation-21 60s infinite;
                animation: particle-animation-21 60s infinite;
        opacity: 0.21;
        height: 10px;
        width: 10px;
        -webkit-animation-delay: -4.2s;
                animation-delay: -4.2s;
        transform: translate3d(75vw, 90vh, 6px);
        background: #d97d26;
        }

        @-webkit-keyframes particle-animation-22 {
        100% {
            transform: translate3d(26vw, 8vh, 24px);
        }
        }

        @keyframes particle-animation-22 {
        100% {
            transform: translate3d(26vw, 8vh, 24px);
        }
        }
        .particle:nth-child(22) {
        -webkit-animation: particle-animation-22 60s infinite;
                animation: particle-animation-22 60s infinite;
        opacity: 0.74;
        height: 8px;
        width: 8px;
        -webkit-animation-delay: -4.4s;
                animation-delay: -4.4s;
        transform: translate3d(13vw, 25vh, 29px);
        background: #d9264d;
        }

        @-webkit-keyframes particle-animation-23 {
        100% {
            transform: translate3d(88vw, 21vh, 9px);
        }
        }

        @keyframes particle-animation-23 {
        100% {
            transform: translate3d(88vw, 21vh, 9px);
        }
        }
        .particle:nth-child(23) {
        -webkit-animation: particle-animation-23 60s infinite;
                animation: particle-animation-23 60s infinite;
        opacity: 0.93;
        height: 7px;
        width: 7px;
        -webkit-animation-delay: -4.6s;
                animation-delay: -4.6s;
        transform: translate3d(63vw, 59vh, 37px);
        background: #26d988;
        }

        @-webkit-keyframes particle-animation-24 {
        100% {
            transform: translate3d(82vw, 49vh, 53px);
        }
        }

        @keyframes particle-animation-24 {
        100% {
            transform: translate3d(82vw, 49vh, 53px);
        }
        }
        .particle:nth-child(24) {
        -webkit-animation: particle-animation-24 60s infinite;
                animation: particle-animation-24 60s infinite;
        opacity: 0.08;
        height: 9px;
        width: 9px;
        -webkit-animation-delay: -4.8s;
                animation-delay: -4.8s;
        transform: translate3d(45vw, 40vh, 86px);
        background: #8ed926;
        }

        @-webkit-keyframes particle-animation-25 {
        100% {
            transform: translate3d(63vw, 16vh, 59px);
        }
        }

        @keyframes particle-animation-25 {
        100% {
            transform: translate3d(63vw, 16vh, 59px);
        }
        }
        .particle:nth-child(25) {
        -webkit-animation: particle-animation-25 60s infinite;
                animation: particle-animation-25 60s infinite;
        opacity: 0.29;
        height: 6px;
        width: 6px;
        -webkit-animation-delay: -5s;
                animation-delay: -5s;
        transform: translate3d(27vw, 82vh, 27px);
        background: #d6d926;
        }

        @-webkit-keyframes particle-animation-26 {
        100% {
            transform: translate3d(35vw, 3vh, 67px);
        }
        }

        @keyframes particle-animation-26 {
        100% {
            transform: translate3d(35vw, 3vh, 67px);
        }
        }
        .particle:nth-child(26) {
        -webkit-animation: particle-animation-26 60s infinite;
                animation: particle-animation-26 60s infinite;
        opacity: 0.98;
        height: 9px;
        width: 9px;
        -webkit-animation-delay: -5.2s;
                animation-delay: -5.2s;
        transform: translate3d(1vw, 30vh, 83px);
        background: #d9c726;
        }

        @-webkit-keyframes particle-animation-27 {
        100% {
            transform: translate3d(75vw, 47vh, 60px);
        }
        }

        @keyframes particle-animation-27 {
        100% {
            transform: translate3d(75vw, 47vh, 60px);
        }
        }
        .particle:nth-child(27) {
        -webkit-animation: particle-animation-27 60s infinite;
                animation: particle-animation-27 60s infinite;
        opacity: 0.47;
        height: 7px;
        width: 7px;
        -webkit-animation-delay: -5.4s;
                animation-delay: -5.4s;
        transform: translate3d(25vw, 49vh, 21px);
        background: #d92691;
        }

        @-webkit-keyframes particle-animation-28 {
        100% {
            transform: translate3d(24vw, 30vh, 34px);
        }
        }

        @keyframes particle-animation-28 {
        100% {
            transform: translate3d(24vw, 30vh, 34px);
        }
        }
        .particle:nth-child(28) {
        -webkit-animation: particle-animation-28 60s infinite;
                animation: particle-animation-28 60s infinite;
        opacity: 0.81;
        height: 7px;
        width: 7px;
        -webkit-animation-delay: -5.6s;
                animation-delay: -5.6s;
        transform: translate3d(28vw, 26vh, 23px);
        background: #d9bb26;
        }

        @-webkit-keyframes particle-animation-29 {
        100% {
            transform: translate3d(74vw, 28vh, 12px);
        }
        }

        @keyframes particle-animation-29 {
        100% {
            transform: translate3d(74vw, 28vh, 12px);
        }
        }
        .particle:nth-child(29) {
        -webkit-animation: particle-animation-29 60s infinite;
                animation: particle-animation-29 60s infinite;
        opacity: 0.21;
        height: 9px;
        width: 9px;
        -webkit-animation-delay: -5.8s;
                animation-delay: -5.8s;
        transform: translate3d(19vw, 37vh, 43px);
        background: #d9262f;
        }

        @-webkit-keyframes particle-animation-30 {
        100% {
            transform: translate3d(77vw, 44vh, 27px);
        }
        }

        @keyframes particle-animation-30 {
        100% {
            transform: translate3d(77vw, 44vh, 27px);
        }
        }
        .particle:nth-child(30) {
        -webkit-animation: particle-animation-30 60s infinite;
                animation: particle-animation-30 60s infinite;
        opacity: 0.57;
        height: 15px;
        width: 15px;
        -webkit-animation-delay: -6s;
                animation-delay: -6s;
        transform: translate3d(48vw, 90vh, 86px);
        background: #6226d9;
        }

    </style>
</head>
<body>
<div id="particle-container">
	<div class="particle-circle"></div>
	<div class="particle-circle"></div>
	<div class="particle-circle"></div>
	<div class="particle-circle"></div>
	<div class="particle-circle"></div>
	<div class="particle-circle"></div>
	<div class="particle-circle"></div>
	<div class="particle-circle"></div>
	<div class="particle-circle"></div>
	<div class="particle-circle"></div>
	<div class="particle-circle"></div>
	<div class="particle-circle"></div>
	<div class="particle-circle"></div>
	<div class="particle-circle"></div>
	<div class="particle-circle"></div>
	<div class="particle"></div>
	<div class="particle"></div>
	<div class="particle"></div>
	<div class="particle"></div>
	<div class="particle"></div>
	<div class="particle"></div>
	<div class="particle"></div>
	<div class="particle"></div>
	<div class="particle"></div>
	<div class="particle"></div>
	<div class="particle"></div>
	<div class="particle"></div>
	<div class="particle"></div>
	<div class="particle"></div>
	<div class="particle"></div>
    <div class="particle"></div>
</div>  
    <div class="container">
        <div class="row">
        <h1>Hi, I'm Andrea</h1>
        <h2>Currently a Sophomore at La Verdad Christian College and an aspiring Software Engineer. Below is my favorite verse, which serves as my life motto as well.</h2>
        <h3>EFESO 2:10</h3>
        <p><em>(Ang Dating Biblia 1905)</em><br>Sapagka't tayo'y kaniyang gawa, na nilalang kay Cristo Jesus para sa mabubuting gawa, na mga inihanda ng Dios nang una upang siya nating lakaran.</p>
        <a href="{{ url('/') }}">Back</a>
        </div>
    </div>
        <!-- https://codepen.io/tutsplus/pen/MrjYJK - Background Source Code -->
</body>
</html>
