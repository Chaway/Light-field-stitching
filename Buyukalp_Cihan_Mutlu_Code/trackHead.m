function boxCorners = trackHead(ourWebcam, detector, trackerFeaturePts)

% Number of detected feature points
ptsNumber = 0;
boxCorners = zeros(4,2);

    % Acquire the current image from the cam and assign it to the
    % variable img.
    img = snapshot(ourWebcam);
    
    % convert the RGB image img to the grayscale intensity image imgI
    imgI = rgb2gray(img);
    
    % Detect the face or track the face
    % if pointNumber is less than 20, do the detection
    if ptsNumber < 20
        
        % return a matrix defining the bounding box
        % that contains the detected object
        % The input image must be a grayscale
        % or truecolor (RGB) image.
        box = detector.step(imgI);
        
        if (isempty(box) == false)
            % converts the input rectangle into a list of
            % four [x y] corner points
            boxCorners = bbox2points(box(1, :));
            
            % Reshape the array containing the corner points
            boxCornersNew = reshape(boxCorners', 1, []);
            
            % Return the video frame image with a box inserted
            img = insertShape(img, 'Polygon', boxCornersNew);
            
            % Detect corners using minimum eigenvalue algorithm
            % and return a cornerPoints object
            % This object contains information about the feature points
            % The input videoFrameGray must be 2-D grayscale image.
            % ROI property defines the rectangular region of interest
            featurePoints = detectMinEigenFeatures(imgI, 'ROI', box(1, :));
            
            % [x y] point coordinates of the points object
            featurePts_xy = featurePoints.Location;
            
            % Get the number of points
            ptsNumber = size(featurePts_xy,1);
            
            % release the interface and all resources used by
            % the interface.
            release(trackerFeaturePts);
            
            % initializes nonlinearity estimator
            initialize(trackerFeaturePts, featurePts_xy, imgI);
            
            previous_pts = featurePts_xy;
        end
        
        % If ptsNumber is enough, do tracking.
    else
        [featurePts_xy, flag] = step(trackerFeaturePts, imgI);
        previousInlierPts = previous_pts(flag, :);
        seenPts = featurePts_xy(flag, :);
        
        % how many points we detected
        ptsNumber = size(seenPts, 1);
        
        % Estimate geometric transform from matching point pairs
        [tform, previousInlierPts, seenPts] = ...
            estimateGeometricTransform(previousInlierPts, seenPts, ...
            'similarity', 'MaxDistance', 5);
        
        % Set the points for tracking
        previous_pts = seenPts;
        setPoints(trackerFeaturePts, previous_pts);
        
        % Apply the forward transformation of tform to the input 3-D
        % bboxpoints to the output bboxpoints
        boxCorners = transformPointsForward(tform, boxCorners);
        
        % Reshape the array containing the corner points
        boxCornersNew = reshape(boxCorners', 1, []);
        
        % Return the video frame image with a box inserted
        img = insertShape(img, 'Polygon', boxCornersNew);
    end