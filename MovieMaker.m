function MovieMaker (name, numFrames, SetupMovie, DrawFrame, saveInDir, options)
	if nargin < 5
		saveInDir = [];
	end
	if nargin < 6
		options = {};
	end
	
	profiling = any(strcmpi(options, 'profile'));
	
	movieState.framesPerSecond = 120;
	movieState.numFrames = numFrames;
	movieState.currentFrame = 0;
	movieState.increment = 1;
	movieState.pause = false;
	movieState.quit = false;
	movieState.close = false;
	movieState.frameNumberAnnotation = [];
	movieState.framesSkippedAnnotation = [];
	movieState.savingMovie = ~isempty(saveInDir);
	
	if movieState.savingMovie && profiling
		warning ('horizon:impulse:optionIgnored', 'Profile option not needed when saving movie.')
	end

	movieState.fig = CascadeFigure(figure('name', name));
	
	movieState = SetupMovie(movieState);
	
	if profiling
		startTime = tic;
		while movieState.currentFrame < movieState.numFrames
			movieState.currentFrame = movieState.currentFrame + 1;
			DrawCurrentFrame ()
		end
		close(movieState.fig)
		fprintf (1, 'Frames per second: %g\n', movieState.numFrames/toc(startTime)) %#ok<*PRTCAL>
	elseif movieState.savingMovie
		if exist(saveInDir, 'dir')
			% Don't just remove it. It might be the wrong directory and contain important
			% stuff.
			error ('horizon:impulse:duplicateDir', '%s already exists', saveInDir)
		end
		mkdir (saveInDir);

		startTime = tic;
		outputFrameNum = 0;			% SetupMovie is allowed to change the increment.
		movieState.currentFrame = 1;
		while movieState.currentFrame <= movieState.numFrames
			outputFrameNum = outputFrameNum + 1;

			DrawCurrentFrame ()
			[im, map] = frame2im(getframe(movieState.fig));
			if isempty(map)
				rgb = im;
			else
				rgb = ind2rgb (im, map);
			end
			imwrite(rgb, sprintf('%s/%07d.jpg', saveInDir, outputFrameNum), 'jpg');
			
			if movieState.currentFrame > 0 && rem(movieState.currentFrame, 10) == 0
				fprintf ('%s\n', PrintStatus (movieState.currentFrame, movieState.numFrames, startTime));
			end
			movieState.currentFrame = movieState.currentFrame + movieState.increment;
		end
		close(movieState.fig)
		fprintf ('%s\n', PrintStatus (movieState.numFrames, movieState.numFrames, startTime));
		fprintf (1, '%d of %d frames saved, %g frames per second\n', outputFrameNum, movieState.numFrames, outputFrameNum/toc(startTime))
	else
		set (movieState.fig, 'KeyPressFcn', @HandleKeypress, 'DeleteFcn', @HandleDelete);

		movieState.handledEvent = false;
		movieState.numFramesSkipped = 0;
		
		ComputeFrameTimes ()
		while ~movieState.quit
			if movieState.pause
				HandleEvents (0.1);
				continue
			elseif HandleEvents (0)
				continue
			end
			
			IncrementFrame ()
			
			secondsToWait = movieState.frameTimes(movieState.currentFrame) - toc(movieState.startTime);
			if secondsToWait < 0 && ~movieState.pause
				movieState.numFramesSkipped = movieState.numFramesSkipped + 1;
				continue		% Too late
			end
			HandleEvents (secondsToWait);
			if movieState.quit
                break;
            end
			DrawCurrentFrame ()
			
			movieState.numFramesSkipped = 0;
			if numFrames < 2
				break
			end
		end
		if movieState.close
			close(movieState.fig)
		end
	end
	
	return	% Only functions below.
	
	function handledEvent = HandleEvents (pauseSeconds)
		assert(~movieState.handledEvent)		% Any events outside drawnow or pause?
		
        handledEvent = false;
        if ~ishandle(movieState.fig)
            return
        end
		previousCurrentFrame = movieState.currentFrame;
		guidata(movieState.fig, movieState)
		if pauseSeconds > 0
			pause (pauseSeconds)
		else
			drawnow
        end
        if ishandle(movieState.fig)
            movieState = guidata(movieState.fig);

            handledEvent = movieState.handledEvent;
            if handledEvent
                movieState.handledEvent = false;
                if movieState.currentFrame ~= previousCurrentFrame
                    DrawCurrentFrame ()
                    ComputeFrameTimes ()
                end
            end
        end
	end
	
	function DrawCurrentFrame ()
		movieState = DrawFrame (movieState, movieState.currentFrame);
		if ~movieState.savingMovie
			frameNumberString = sprintf('%d of %d', movieState.currentFrame, movieState.numFrames);
			if ~isempty(movieState.frameNumberAnnotation)
				set (movieState.frameNumberAnnotation, 'string', frameNumberString);
			else
				movieState.frameNumberAnnotation = ...
					annotation('textbox',[.01 .01 .12 .03], ...
								'String', frameNumberString, ...
								'BackgroundColor', 'w', ...
								'FitBoxToText', 'off', ...
								'HorizontalAlignment', 'center', ...
								'Interpreter', 'none');
			end
	
			if isfield (movieState, 'numFramesSkipped')
				framesSkippedString = sprintf('%.3g FPS %3d%% skipped', movieState.framesPerSecond, round(100*movieState.numFramesSkipped/(movieState.numFramesSkipped+1)));
				if ~isempty(movieState.framesSkippedAnnotation)
					set (movieState.framesSkippedAnnotation, 'string', framesSkippedString);
				else
					movieState.framesSkippedAnnotation = ...
						annotation('textbox',[.99-.12 .01 .12 .03], ...
									'String', framesSkippedString, ...
									'BackgroundColor', 'w', ...
									'FitBoxToText', 'off', ...
									'HorizontalAlignment', 'center', ...
									'Interpreter', 'none');
				end
			end
		end
	end
	
	function HandleKeypress(~, event)
		movieState = guidata(movieState.fig);
		movieState.handledEvent = true;
		switch event.Character
			case ' '
				if movieState.pause
					IncrementFrame ()
				else
					movieState.pause = true;
				end
			case 'p'
				movieState.pause = ~movieState.pause;
				ComputeFrameTimes ()
			case 'f'
				if movieState.increment < 0
					movieState.increment = -movieState.increment;
					ComputeFrameTimes ()
				end
				if movieState.pause
					IncrementFrame ()
				end
			case 'r'
				if movieState.increment > 0
					movieState.increment = -movieState.increment;
					ComputeFrameTimes ()
				end
				if movieState.pause
					IncrementFrame ()
				end
			case 'b'
				movieState.currentFrame = 1;
				movieState.increment = 1;
			case 'e'
				movieState.currentFrame = movieState.numFrames;
				movieState.increment = -1;
			case '+'
				movieState.pause = false;
				movieState.framesPerSecond = min([movieState.framesPerSecond * 2, 480]);
				ComputeFrameTimes ()
			case '-'
				movieState.pause = false;
				movieState.framesPerSecond = max([movieState.framesPerSecond / 2, 1/2]);
				ComputeFrameTimes ()
			case 'q'
				set (movieState.fig, 'KeyPressFcn', []);
				movieState.quit = true;
			case 'x'
				set (movieState.fig, 'KeyPressFcn', []);
				movieState.quit = true;
				movieState.close = true;
			case 'h'
				fprintf (1, '<space>	step one frame\n')
				fprintf (1, 'p          play/pause\n')
				fprintf (1, 'f r        forward/reverse\n')
				fprintf (1, 'b e        jump to beginning/end\n')
				fprintf (1, '+ -        faster/slower\n')
				fprintf (1, 'q          quit\n')
				fprintf (1, 'x          quit and close window\n')
		end
		guidata(movieState.fig, movieState)
	end
	
	function HandleDelete (~, ~)
		movieState.quit = true;
	end
	
	function ComputeFrameTimes ()
		if ~movieState.pause
			movieState.startTime = tic;
			if movieState.increment > 0
				movieState.frameTimes = ((1:movieState.numFrames) - movieState.currentFrame)/movieState.framesPerSecond;
			else
				movieState.frameTimes = ((movieState.numFrames:-1:1) - (movieState.numFrames - movieState.currentFrame + 1))/movieState.framesPerSecond;
			end
		end
	end
	
	function IncrementFrame ()
		movieState.currentFrame = movieState.currentFrame + movieState.increment;
		if movieState.currentFrame > movieState.numFrames
			movieState.pause = true;
			movieState.currentFrame = movieState.numFrames;
			movieState.increment = -1;
		elseif movieState.currentFrame < 1
			movieState.pause = true;
			movieState.currentFrame = 1;
			movieState.increment = 1;
		end
	end
	
end
