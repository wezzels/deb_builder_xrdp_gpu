<?php
    // Default values:
    $logFile = __DIR__.'/var/log/syslog';
    $maxLines = 100;
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title>Symfony Log Viewer</title>
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/framy/latest/css/framy.min.css">
        <style>
            body { padding: 40px; color: black }
            form { margin-bottom: 40px; }
            h1 { margin: 0px 0px 40px 0px }

            .sidebar { float: left; width: 300px }
            .content { margin-left: 340px }
            @media (max-width: 1023px) {
		.sidebar { float: none; width: 100% }
		.content { margin-left: 0 }
            }

            .entry { margin: 20px 0px; padding: 10px; background-color: #EEE; cursor: pointer }
            .entry.hidden {  overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

            .date-time { color: #666 }

            .type { padding: 3px 5px; border-radius: 3px; font-weight: bold; background-color: #2f3241; color: white }
            .type.debug { background-color: #4ce276 }
            .type.info { background-color: #5bb8fd }
	    .type.notice { background-color: #f9d65e; }
            .type.warning { background-color: #ff9900; }
            .type.error { background-color: #f36362 }
            .type.critical { background-color: #ff33cc }
	    .type.emergency { }

            .message .bracket { color: #666 }
            .meta { color: #666 }
        </style>
        <script src="https://code.jquery.com/jquery-3.1.0.min.js"></script>
    </head>
    <body>
	<div class="sidebar">
		<form action="" method="POST">
		    <h1>Log</h1>

		    <div class="form-element">
		        <label for="logfile">Path of log file</label>
		        <input type="text" name="logfile" id="logfile" class="form-field" value="<?php echo $_POST['logfile'] ?? $logFile ?>">
		    </div>

		    <div class="form-element">
		        <label for="max_lines">Process max. lines</label>
		        <input type="number" name="max_lines" id="max_lines" class="form-field" value="<?php echo $_POST['max_lines'] ?? $maxLines ?>">
		    </div>

		    <hr>

		    <div class="form-element filters">
		        <label>Level Filters</label>

			<!-- According to https://github.com/php-fig/fig-standards/blob/master/accepted/PSR-3-logger-interface.md -->

			<div class="columns">
		            <div class="lg-4">
				<div class="checkbox-inline">
				    <input id="debug" name="debug" type="checkbox" <?php echo isset($_POST['debug']) ? 'checked="checked"' : '' ?>>
				    <label for="debug">Debug</label>
				</div>
		            </div>
		            <div class="lg-4">
				<div class="checkbox-inline">
				    <input id="info" name="info" type="checkbox" <?php echo isset($_POST['info']) ? 'checked="checked"' : '' ?>>
				    <label for="info">Info</label>
				</div>
		            </div>
			</div>
			<div class="columns">
		            <div class="lg-4">
				<div class="checkbox-inline">
				    <input id="notice" name="notice" type="checkbox" <?php echo isset($_POST['notice']) ? 'checked="checked"' : '' ?>>
				    <label for="notice">Notice</label>
				</div>
		            </div>
		            <div class="lg-4">
				<div class="checkbox-inline">
				    <input id="warning" name="warning" type="checkbox" <?php echo isset($_POST['warning']) ? 'checked="checked"' : '' ?>>
				    <label for="warning">Warning</label>
				</div>
		            </div>
			</div>
			<div class="columns">
		            <div class="lg-4">
				<div class="checkbox-inline">
				    <input id="error" name="error" type="checkbox" <?php echo isset($_POST['error']) ? 'checked="checked"' : '' ?>>
				    <label for="error">Error</label>
				</div>
		            </div>
		            <div class="lg-4">
				<div class="checkbox-inline">
				    <input id="critical" name="critical" type="checkbox" <?php echo isset($_POST['critical']) ? 'checked="checked"' : '' ?>>
				    <label for="critical">Critical</label>
				</div>
		            </div>
			</div>
			<div class="columns">
		            <div class="lg-4">
				<div class="checkbox-inline">
				    <input id="alert" name="alert" type="checkbox" <?php echo isset($_POST['alert']) ? 'checked="checked"' : '' ?>>
				    <label for="alert">Alert</label>
				</div>
		            </div>
		            <div class="lg-4">
				<div class="checkbox-inline">
				    <input id="emergency" name="emergency" type="checkbox" <?php echo isset($_POST['emergency']) ? 'checked="checked"' : '' ?>>
				    <label for="emergency">Emergency</label>
				</div>
		            </div>
			</div>
		    </div>

		    <hr>

		    <button class="button" type="submit" name="refresh" value="refresh" title="Reload the log file"><i class="icon icon-refresh"></i> Refresh</button>
		    <button class="button" tybe="button" name="show" value="show" title="Display the content of the log file without parsing"><i class="icon icon-eye"></i> Show</button>
		    <button class="button" type="submit" name="clear" value="clear" title="Delete the log file"><i class="icon icon-trash-a"></i> Clear</button>
		</form>
        </div>
	<div class="content">
		<div class="log">
		    <?php
		        $logFile = $_POST['logfile'] ?? $logFile;
		        $maxLines = $_POST['max_lines'] ?? $maxLines;

		        if ($logFile) {
		            if (! file_exists($logFile)) {
		                die('Log file does not exist.');
		            }
		            if (isset($_POST['clear'])) {
		                unlink($logFile);
		            } else {
		                $lines = file($logFile);

			        if (isset($_POST['show'])) {
				    echo '<pre>';				
				    foreach ($lines as $line) {
					echo $line.'<br>';
				    }
				    echo '</pre><hr>';
			        }

		                $dateLength = strlen('[yyyy-mm-dd hh:mm:ss] ');
				$lineNumber = 0;
		                foreach ($lines as $line) {
		                    $lineNumber++;

		                    $dateTime = substr($line, 0, $dateLength);
		                    $line = substr($line, $dateLength);

		                    $pos = strpos($line, ':');
		                    $type = substr($line, 0, $pos);
		                    $line = substr($line, $pos + 1);

		                    $pos = strpos($type, '.');
		                    $level = strtolower(substr($type, $pos + 1));

		                    $line = str_replace('{', '<span class="bracket">{', $line);
		                    $line = str_replace('}', '}</span>', $line);

		                    echo '<div class="entry hidden">';
		                    echo '<span class="date-time">' . $dateTime . '</span> ';
		                    echo '<span class="type ' . $level . '">' . $type . '</span> ';
		                    echo '<span class="message">' . $line . '</span>';
		                    echo '</div>';

				    if ($lineNumber >= $maxLines) {
					break;
				    }
		                }

		                echo '<small class="meta">Logfile <em>'.$logFile.'</em> with '.sizeof($lines).' lines and '.filesize($logFile).' Bytes total</small>';
		            }
		        }
		    ?>
		</div>
	</div>

        <script>
            (function()
            {
		$('form').submit(function(event)
		{
			if (event.originalEvent && event.originalEvent.explicitOriginalTarget && event.originalEvent.explicitOriginalTarget.name == 'clear') {
				var clear = confirm('Logdatei leeren?');
			
				if (! clear) {
					event.preventDefault();
					return false;
				}
			}
		});

                $('.entry').click(function()
                {
                    $(this).toggleClass('hidden');
                });

                var applyFilters = function()
                {
                    var filters = new Array();

                    $('.filters input').each(function()
                    {
                        if (this.checked) {
                            filters.push($(this).attr('name'));
                        }
                    });

                    $('.entry').hide();
                    $('.entry').each(function()
                    {
                        var $entry = $(this);
                        var $type = $entry.find('.type');
                        filters.forEach(function(level)
                        {
                            if ($type.hasClass(level)) {
                                $entry.show();
                            }
                        });
                    });
                };
                applyFilters();

                $('.filters input').click(applyFilters);
            })();
        </script>
    </body>
</html>
