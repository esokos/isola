function [XX,I] = rdmseed(varargin)
%RDMSEED Read miniSEED format file.
%	X = RDMSEED(F) reads file F and returns a M-by-1 structure X containing
%	M blocks ("data records") of a miniSEED file with headers, blockettes, 
%	and data in dedicated fields, in particular, for each data block X(i):
%		         t: time vector (DATENUM format)
%		         d: data vector (double)
%		BLOCKETTES: existing blockettes (substructures)
%
%	Known blockettes are 100, 500, 1000, 1001 and 2000. Others will be
%	ignored with a warning message.
%
%	X = RDMSEED(F,ENCODINGFORMAT,WORDORDER,RECORDLENGTH), when file F does 
%	not include the Blockette 1000 (like Seismic Handler outputs), specifies:
%		- ENCODINGFORMAT: FDSN code (see below); default is 10 = Steim-1;
%		- WORDORDER: 1 = big-endian (default), 0 = little-endian;
%		- RECORDLENGTH: must be a power of 2, at least 256 (default is 4096).
%	If the file contains Blockette 1000 (which is mandatory in the SEED 
%	convention...), these 3 arguments are ignored.
%
%	X = RDMSEED without input argument opens user interface to select the 
%	file from disk.
%
%	[X,I] = RDMSEED(...) returns a N-by-1 structure I with N the detected 
%	number of different channels, and the following fields:
%	    ChannelFullName: channel name,
%	        XBlockIndex: channel's vector index into X,
%	         ClockDrift: vector of time interval errors, in seconds,
%	                     between each data block (relative to sampling
%	                     period). This can be compared to "Max Clock Drift"
%	                     value of a Blockette 52.
%	                        = 0 in perfect case
%	                        < 0 tends to overlapping
%	                        > 0 tends to gapping
%	  OverlapBlockIndex: index of blocks (into X) having a significant 
%	                     overlap with previous block (less than 0.5
%	                     sampling period).
%	        OverlapTime: time vector of overlapped blocks (DATENUM format).
%	      GapBlockIndex: index of blocks (into X) having a significant gap
%	                     with next block (more than 0.5 sampling period).
%	            GapTime: time vector of gapped blocks (DATENUM format).
%
%	RDMSEED(...) without output arguments plots the imported signal by 
%	concatenating all the data records, in one single plot if single channel
%	is detected, or subplots for multi-channels file. Gaps are shown with
%	red stars, overlaps with green circles.
%
%	[...] = RDMSEED(F,...,'plot') forces the plot with output arguments.
%
%	Some instructions for usage of the returned structure:
%	
%	- to get concatenated time and data vectors from a single-channel file:
%		X = rdmseed(f,'plot');
%		t = cat(1,X.t);
%		d = cat(1,X.d);
%
%	- to get the list of channels in a multi-channel file:
%		[X,I] = rdmseed(f);
%		cat(1,I.ChannelFullName)
%
%	- to extract the station component i from a multi-channel file:
%		[X,I] = rdmseed(f);
%		k = I(i).XBlockIndex;
%		plot(cat(1,X(k).t),cat(1,X(k).d))
%		datetick('x')
%		title(I(i).ChannelFullName)
%
%	Known encoding formats are the following FDSN codes:
%		 0: ASCII
%		 1: 16-bit integer
%		 2: 24-bit integer (untested)
%		 3: 32-bit integer
%		 4: IEEE float
%		 5: IEEE double (untested)
%		10: Steim-1
%		11: Steim-2
%		12: GEOSCOPE 24-bit (untested)
%		13: GEOSCOPE 16/3-bit gain ranged
%		14: GEOSCOPE 16/4-bit gain ranged (untested)
%		19: Steim-3 (alpha and untested)
%
%	Author: François Beauducel <beauducel@ipgp.fr>
%		Institut de Physique du Globe de Paris
%	Created: 2010-09-17
%	Updated: 2011-07-21
%
%	Aknowledgments:
%		Ljupco Jordanovski, Jean-Marie Saurel, Mohamed Boubacar.
%
%	References:
%		IRIS (2010), SEED Reference Manual: SEED Format Version 2.4, May 2010,
%		  IFDSN/IRIS/USGS, http://www.iris.edu
%		Trabant C. (2010), libmseed: the Mini-SEED library, IRIS DMC.
%		Steim J.M. (1994), 'Steim' Compression, Quanterra Inc.

%	History:
%		[2011-07-21]
%			- Validation of ASCII encoding format
%			- Blockettes are now stored in substructures below a single
%			  field X.BLOCKETTES
%			- Add import of blockettes 500 and 2000
%			- Accept multi-channel files with ASCII blocks (logs) and 
%			  various data coding
%		[2010-10-16]
%			- Alpha-version of Steim-3 decoding...
%			- Extend output parameters with channel detection
%			- Add gaps and overlaps on plots
%			- Add possibility to force the plot
%		[2010-10-02]
%			- Add the input formats for GEOSCOPE multiplexed old data files
%			- Additional output argument with gap and overlap analysis
%			- Create a plot when no output argument are specified
%			- Optimize script coding (30 times faster STEIM decoding!)
%
%		[2010-09-28]
%			- Correction of a problem with STEIM-1 nibble 3 decoding (one 
%			  32-bit difference)
%			- Add reading of files without blockette 1000 with additional
%			  input arguments (like Seismic Handler output files).
%			- Uses warning() function instead of fprintf().
%
%	Copyright (c) 2010, François Beauducel, covered by BSD License.
%	All rights reserved.
%
%	Redistribution and use in source and binary forms, with or without 
%	modification, are permitted provided that the following conditions are 
%	met:
%
%	   * Redistributions of source code must retain the above copyright 
%	     notice, this list of conditions and the following disclaimer.
%	   * Redistributions in binary form must reproduce the above copyright 
%	     notice, this list of conditions and the following disclaimer in 
%	     the documentation and/or other materials provided with the distribution
%	                           
%	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
%	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
%	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
%	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
%	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
%	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
%	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
%	POSSIBILITY OF SUCH DAMAGE.

error(nargchk(0,5,nargin))

% default input arguments
makeplot = 0;
ef = 10;
wo = 1;
rl = 2^12;

if nargin < 1
	[filename,pathname] = uigetfile('*','Please select a miniSEED file...');
	f = fullfile(pathname,filename);
else
	f = varargin{1};
end

if ~ischar(f) | ~exist(f,'file')
	error('File %s does not exist.',f);
end

if nargin > 1
	makeplot = strcmp(varargin(end),'plot');
end

if nargin > (1 + makeplot)
	ef = varargin{2};
	if ~isnumeric(ef) | ~any(ef==[0:5,10:19,30:33])
		error('Argument ENCODINGFORMAT must be a valid FDSN code value.');
	end
end

if nargin > (2 + makeplot)
	wo = varargin{3};
	if ~isnumeric(wo) | (wo ~= 0 & wo ~= 1)
		error('Argument WORDORDER must be 0 or 1.');
	end
end

if nargin > (3 + makeplot)
	rl = varargin{4};
	if ~isnumeric(rl) | rl < 256 | rem(log(rl)/log(2),1) ~= 0
		error('Argument RECORDLENGTH must be a power of 2 and greater or equal to 256.');
	end
end

if nargout == 0
	makeplot = 1;
end

% maximum number of channels for plotting y-labels
max_channel_label = 6;

LittleEndian = 0;

fid = fopen(f,'rb','ieee-be');
header = fread(fid,20,'*char');

% --- tests if the header is mini-SEED
% the 7th character must be one of the "data header/quality indicator", usually 'D'
if isempty(findstr(header(7),'DRMQ'))
	if ~isempty(findstr(header(7),'VAST'))
		s = ' (seems to be a SEED Volume)';
	else
		s = '';
	end
	error('File is not in mini-SEED format%s. Cannot read it.',s);
end

% --- tests little-endian or big-endian
% if the 2-byte year is greater than 2056, file is probably little-endian
% (Note: idea taken from Ljupco Jordanovski scripts. Thanks!)
Year = fread(fid,1,'uint16');
if Year < 2056
	fseek(fid,0,'bof');
else
	LittleEndian = 1;
	fclose(fid);
	fid = fopen(f,'rb','ieee-le');
end

i = 1;
FileOffset = 0;

while ~feof(fid)
	X(i) = read_data_record(fid,FileOffset,LittleEndian,ef,wo,rl);
	FileOffset = ftell(fid);
	i = i + 1;
	fread(fid,1,'char');	% this is to force EOF=1 on last record.
end

fclose(fid);

if nargout > 0
	XX = X;
end

% --- analyses data
if nargout > 1 | makeplot

	% test if the file is multiplexed or a single channel
	un = unique(cellstr(cat(1,X.ChannelFullName)));
	nc = numel(un);
	
	for i = 1:nc
		k = find(strcmp(cellstr(cat(1,X.ChannelFullName)),un{i}));
		I(i).ChannelFullName = un{i};
		I(i).XBlockIndex = k;
		I(i).ClockDrift = ([diff(cat(1,X(k).RecordStartTimeMATLAB));NaN]*86400 - cat(1,X(k).NumberSamples)./cat(1,X(k).SampleRate))./cat(1,X(k).NumberSamples);
		I(i).OverlapBlockIndex = k(find(I(i).ClockDrift.*cat(1,X(k).NumberSamples).*cat(1,X(k).SampleRate) < -.5) + 1);
		I(i).OverlapTime = cat(1,X(I(i).OverlapBlockIndex).RecordStartTimeMATLAB);
		I(i).GapBlockIndex = k(find(I(i).ClockDrift.*cat(1,X(k).NumberSamples).*cat(1,X(k).SampleRate) > .5) + 1);
		I(i).GapTime = cat(1,X(I(i).GapBlockIndex).RecordStartTimeMATLAB);
	end
end


% --- plots the data
if makeplot

	figure
	
	xlim = [min(cat(1,X.t)),max(cat(1,X.t))];

	% test if all data records have the same sampling rate
	sr = unique(cat(1,X.SampleRate));
	if numel(sr) == 1
		sr_text = sprintf('%g Hz samp.',sr);
	else
		sr_text = sprintf('%d different samp. rates',numel(sr));
	end
	
	% test if all data records have the same encoding format
	ef = unique(cellstr(cat(1,X.EncodingFormatName)));
	if numel(ef) == 1
		ef_text = sprintf('%s',ef{:});
	else
		ef_text = sprintf('%d different encod. formats',numel(ef));
	end
			
	if nc == 1
		plot(cat(1,X.t),cat(1,X.d))
		hold on
		for i = 1:length(I.GapBlockIndex)
			plot(I.GapTime(i),X(I.GapBlockIndex(i)).d(1),'*r')
		end
		for i = 1:length(I.OverlapBlockIndex)
			plot(I.OverlapTime(i),X(I.OverlapBlockIndex(i)).d(1),'og')
		end
		hold off
		set(gca,'XLim',xlim)
		datetick('x','keeplimits')
		grid on
		xlabel(sprintf('Time\n(%s to %s)',datestr(xlim(1)),datestr(xlim(2))))
		ylabel('Counts')
		title(sprintf('mini-SEED file "%s"\n%s (%d records - %g data - %s - %s)', ...
			f,un{1},length(X),numel(cat(1,X.d)),sr_text,ef_text),'Interpreter','none')
	else
		% plot is done only for real data channels...
		for i = 1:nc
			subplot(nc*2,1,i*2 + (-1:0))
			k = I(i).XBlockIndex;
			if ~any(strcmp('ASCII',cellstr(cat(1,X(k).EncodingFormatName))))
				plot(cat(1,X(k).t),cat(1,X(k).d))
				hold on
				for ii = 1:length(I(i).GapBlockIndex)
					plot(I(i).GapTime(ii),X(I(i).GapBlockIndex(ii)).d(1),'*r')
				end
				for ii = 1:length(I(i).OverlapBlockIndex)
					plot(I(i).OverlapTime(ii),X(I(i).OverlapBlockIndex(ii)).d(1),'og')
				end
				hold off
			end
			set(gca,'XLim',xlim,'FontSize',8)
			h = ylabel(un{i},'Interpreter','none');
			if nc > max_channel_label
				set(gca,'YTick',[])
				set(h,'Rotation',0,'HorizontalAlignment','right','FontSize',8)
			end
			datetick('x','keeplimits')
			set(gca,'XTickLabel',[])
			grid on
			if i == 1
				title(sprintf('mini-SEED file "%s"\n%d channels (%d records - %g data - %s - %s)', ...
					f,length(un),length(X),numel(cat(1,X(k).d)),sr_text,ef_text),'Interpreter','none')
			end
			if i == nc
				datetick('x','keeplimits')
				xlabel(sprintf('Time\n(%s to %s)',datestr(xlim(1)),datestr(xlim(2))))
			end
		end
		v = version;
		if str2double(v(1))>=7
			linkaxes(findobj('type','axes'),'x')
		end
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = read_data_record(fid,offset,le,ef,wo,rl)
% read_data_record(FID,OFFSET,LE,EF,WO,RL) reads the data record starting
%	at byte OFFSET (from begining of the open file FID), using parameters
%	LE (=1 for litte-endian file encoding), and default parameters if no
%	Blockette 1000 will be found: EF = encoding format, WO = word order, 
%	and RL = record length.
%	Returns a structure D.

fseek(fid,offset,'bof');

% --- read fixed section of Data Header (48 bytes)
D.SequenceNumber		= fread(fid,6,'*char')';
D.DataQualityIndicator	= fread(fid,1,'*char');
D.ReservedByte			= fread(fid,1,'*char');
D.StationIdentifierCode = fread(fid,5,'*char')';
D.LocationIdentifier	= fread(fid,2,'*char')';
D.ChannelIdentifier		= fread(fid,3,'*char')';
D.NetworkCode			= fread(fid,2,'*char')';
D.ChannelFullName = sprintf('%s:%s:%s',D.NetworkCode,D.StationIdentifierCode,D.ChannelIdentifier);

% Start Time decoding
D.RecordStartTime = readbtime(fid);
D.RecordStartTimeISO = sprintf('%4d-%03d %02d:%02d:%07.4f',D.RecordStartTime);
D.RecordStartTimeMATLAB = datenum([D.RecordStartTime(1),0,D.RecordStartTime(2:5)]);

D.NumberSamples			= fread(fid,1,'uint16');

% Sample Rate decoding
SampleRateFactor		= fread(fid,1,'int16=>double');
SampleRateMultiplier	= fread(fid,1,'int16=>double');
if SampleRateFactor > 0
	if SampleRateMultiplier >= 0
		D.SampleRate = SampleRateFactor*SampleRateMultiplier;
	else
		D.SampleRate = -1*SampleRateFactor/SampleRateMultiplier;
	end
else
	if SampleRateMultiplier >= 0
		D.SampleRate = -1*SampleRateMultiplier/SampleRateFactor;
	else
		D.SampleRate = 1/(SampleRateFactor*SampleRateMultiplier);
	end
end

D.ActivityFlags			= fread(fid,1,'uint8');
D.IOFlags				= fread(fid,1,'uint8');
D.DataQualityFlags		= fread(fid,1,'uint8');
D.NumberBlockettesFollow = fread(fid,1,'uint8');
D.TimeCorrection		= fread(fid,1,'float32');
D.OffsetBeginData		= fread(fid,1,'uint16');
D.OffsetFirstBlockette	= fread(fid,1,'uint16');

% --- read the blockettes
OffsetNextBlockette = D.OffsetFirstBlockette;

D.BLOCKETTES = [];
b2000 = 0;	% Number of Blockette 2000

for i = 1:D.NumberBlockettesFollow
	fseek(fid,offset + OffsetNextBlockette,'bof');
	BlocketteType = fread(fid,1,'uint16');
	
	switch BlocketteType
		
		case 1000
			% BLOCKETTE 1000 = Data Only SEED (8 bytes)
			OffsetNextBlockette = fread(fid,1,'uint16');
            D.BLOCKETTES.B1000.EncodingFormat = fread(fid,1,'uint8');
			D.BLOCKETTES.B1000.WordOrder = fread(fid,1,'uint8');
			D.BLOCKETTES.B1000.DataRecordLength = fread(fid,1,'uint8');
			D.BLOCKETTES.B1000.Reserved = fread(fid,1,'uint8');
			
		case 1001
			% BLOCKETTE 1001 = Data Extension (8 bytes)
			OffsetNextBlockette = fread(fid,1,'uint16');
			D.BLOCKETTES.B1001.TimingQuality = fread(fid,1,'uint8');
			D.BLOCKETTES.B1001.Micro_sec = fread(fid,1,'int8');
			D.BLOCKETTES.B1001.Reserved = fread(fid,1,'uint8');
			D.BLOCKETTES.B1001.FrameCount = fread(fid,1,'uint8');
			
		case 100
			% BLOCKETTE 100 = Sample Rate (12 bytes)
			OffsetNextBlockette = fread(fid,1,'uint16');
			D.BLOCKETTES.B100.ActualSampleRate = fread(fid,1,'float32');
			D.BLOCKETTES.B100.Flags = fread(fid,1,'uint8');
			D.BLOCKETTES.B100.Reserved = fread(fid,1,'uint8');
		
		case 500
			% BLOCKETTE 500 = Timing (200 bytes)
			OffsetNextBlockette = fread(fid,1,'uint16');
			D.BLOCKETTES.B500.VCOCorrection = fread(fid,1,'float32');
			D.BLOCKETTES.B500.TimeOfException = readbtime(fid);
			D.BLOCKETTES.B500.MicroSec = fread(fid,1,'int8');
			D.BLOCKETTES.B500.ReceptionQuality = fread(fid,1,'uint8');
			D.BLOCKETTES.B500.ExceptionCount = fread(fid,1,'uint16');
			D.BLOCKETTES.B500.ExceptionType = fread(fid,16,'*char')';
			D.BLOCKETTES.B500.ClockModel = fread(fid,32,'*char')';
			D.BLOCKETTES.B500.ClockStatus = fread(fid,128,'*char')';
		
		case 2000
			% BLOCKETTE 2000 = Opaque Data (variable length)
			b2000 = b2000 + 1;
			OffsetNextBlockette = fread(fid,1,'uint16');
			BlocketteLength = fread(fid,1,'uint16');
			OffsetOpaqueData = fread(fid,1,'uint16');
			D.BLOCKETTES.B2000(b2000).RecordNumber = fread(fid,1,'uint32');
			D.BLOCKETTES.B2000(b2000).DataWordOrder = fread(fid,1,'uint8');
			D.BLOCKETTES.B2000(b2000).Flags = fread(fid,1,'uint8');
			NumberHeaderFields = fread(fid,1,'uint8');
			HeaderFields = splitfield(fread(fid,OffsetOpaqueData-15,'*char')','~');
			D.BLOCKETTES.B2000(b2000).HeaderFields = HeaderFields(1:NumberHeaderFields);
			% Opaque data are stored as a single char string, but must be
			% decoded using appropriate format (e.g., Quanterra Q330)
			D.BLOCKETTES.B2000(b2000).OpaqueData = fread(fid,BlocketteLength-OffsetOpaqueData,'*char')';
		
		otherwise
			OffsetNextBlockette = fread(fid,1,'uint16');
			warning('Unknown Blockette number %d (%s)!\n',BlocketteType,D.ChannelFullName);
	end
end

% --- read the data stream
fseek(fid,offset + D.OffsetBeginData,'bof');

if isfield(D.BLOCKETTES,'B1000')
	EncodingFormat = D.BLOCKETTES.B1000.EncodingFormat;
	WordOrder = D.BLOCKETTES.B1000.WordOrder;
	D.DataRecordSize = 2^D.BLOCKETTES.B1000.DataRecordLength;
else
	EncodingFormat = ef;
	WordOrder = wo;
	D.DataRecordSize = rl;
end

uncoded = 0;

D.d = NaN;
D.t = NaN;

switch EncodingFormat
	
	case 0
		% --- decoding format: ASCII text
		D.EncodingFormatName = 'ASCII';
		D.d = fread(fid,D.DataRecordSize - D.OffsetBeginData,'*char')';

	case 1
		% --- decoding format: 16-bit integers
		D.EncodingFormatName = 'INT16';
		dd = fread(fid,(D.DataRecordSize - D.OffsetBeginData)/2,'*int16');
		if xor(~WordOrder,le)
			dd = swapbytes(dd);
		end
		D.d = dd(1:D.NumberSamples);
		
	case 2
		% --- decoding format: 24-bit integers
		D.EncodingFormatName = 'INT24';
		dd = fread(fid,(D.DataRecordSize - D.OffsetBeginData)/3,'bit24=>int32');
		if xor(~WordOrder,le)
			dd = swapbytes(dd);
		end
		D.d = dd(1:D.NumberSamples);
		
	case 3
		% --- decoding format: 32-bit integers
		D.EncodingFormatName = 'INT32';
		dd = fread(fid,(D.DataRecordSize - D.OffsetBeginData)/4,'*int32');
		if xor(~WordOrder,le)
			dd = swapbytes(dd);
		end
		D.d = dd(1:D.NumberSamples);
		
	case 4
		% --- decoding format: IEEE floating point
		D.EncodingFormatName = 'FLOAT32';
		dd = fread(fid,(D.DataRecordSize - D.OffsetBeginData)/4,'*float');
		if xor(~WordOrder,le)
			dd = swapbytes(dd);
		end
		D.d = dd(1:D.NumberSamples);
		
	case 5
		% --- decoding format: IEEE double precision floating point
		D.EncodingFormatName = 'FLOAT64';
		dd = fread(fid,(D.DataRecordSize - D.OffsetBeginData)/8,'*double');
		if xor(~WordOrder,le)
			dd = swapbytes(dd);
		end
		D.d = dd(1:D.NumberSamples);

	case {10,11,19}
		% --- decoding formats: STEIM-1 and STEIM-2 compression
		%    (c) Joseph M. Steim, Quanterra Inc., 1994
		steim = find(EncodingFormat==[10,11,19]);
		D.EncodingFormatName = {sprintf('STEIM%d',steim)};
		
		% Steim compression decoding strategy optimized for Matlab
		% -- by F. Beauducel, October 2010 --
		%
		%	1. loads all data into a single 16xM uint32 array
		%	2. gets all nibbles from the first row splitted into 2-bit values
		%	3. for each possible nibble value, selects (find) and decodes
		%	   (bitsplit) all the corresponding words, and stores results
		%	   in a 4xN (STEIM1) or 7xN (STEIM2) array previously filled with
		%	   NaN's. For STEIM2 with nibbles 2 or 3, decodes also dnib values
		%	   (first 2-bit of the word)
		%	5. reduces this array with non-NaN values only
		%	6. integrates with cumsum
		%
		% This method is about 30 times faster than a 'C-like' loops coding...
		
		frame32 = fread(fid,[16,(D.DataRecordSize - D.OffsetBeginData)/64],'*uint32');
		if xor(~WordOrder,le)
			frame32 = swapbytes(frame32);
		end
		
		% specific processes for STEIM-3
		if steim == 3
			% first bit = 1 means second differences
			SecondDiff = bitshift(frame32(1,:),-31);
			% checks for "squeezed flag"... and replaces frame32(1,:)
			squeezed = bitand(bitshift(frame32(1,:),-24),bitcmp(0,2^7));
			k = find(bitget(squeezed,7));
			if ~isempty(k)
				moredata24 = bitand(frame32(1,k),bitcmp(0,2^24));
				k = find(squeezed == 80);	% upper nibble 8-bit = 0x50
				if ~isempty(k)
					frame32(1,k) = hex2dec('15555555');
				end
				k = find(squeezed == 96);	% upper nibble 8-bit = 0x60
				if ~isempty(k)
					frame32(1,k) = hex2dec('2aaaaaaa');
				end
				k = find(squeezed == 112);	% upper nibble 8-bit = 0x70
				if ~isempty(k)
					frame32(1,k) = hex2dec('3fffffff');
				end
			end
		end

		% nibbles is an array of the same size as frame32...
		nibbles = bitand(bitshift(repmat(frame32(1,:),16,1),repmat(-30:2:0,size(frame32,2),1)'),bitcmp(0,2));
		x0 = bitsign(frame32(2,1),32);	% forward integration constant
		xn = bitsign(frame32(3,1),32);	% reverse integration constant
		
		switch steim
			
		case 1
			% STEIM-1: 3 cases following the nibbles
			ddd = NaN*ones(4,numel(frame32));	% initiates array with NaN
			k = find(nibbles == 1);				% nibble = 1 : four 8-bit differences
			if ~isempty(k)
				ddd(1:4,k) = bitsplit(frame32(k),32,8);
			end
			k = find(nibbles == 2);				% nibble = 2 : two 16-bit differences
			if ~isempty(k)
				ddd(1:2,k) = bitsplit(frame32(k),32,16);
			end
			k = find(nibbles == 3);				% nibble = 3 : one 32-bit difference
			if ~isempty(k)
				ddd(1,k) = bitsign(frame32(k),32);
			end

		case 2	
			% STEIM-2: 7 cases following the nibbles and dnib
			ddd = NaN*ones(7,numel(frame32));	% initiates array with NaN
			k = find(nibbles == 1);				% nibble = 1 : four 8-bit differences
			if ~isempty(k)
				ddd(1:4,k) = bitsplit(frame32(k),32,8);
			end
			k = find(nibbles == 2);				% nibble = 2 : must look in dnib
			if ~isempty(k)
				dnib = bitshift(frame32(k),-30);
				kk = k(dnib == 1);		% dnib = 1 : one 30-bit difference
				if ~isempty(kk)
					ddd(1,kk) = bitsign(frame32(kk),30);
				end
				kk = k(dnib == 2);		% dnib = 2 : two 15-bit differences
				if ~isempty(kk)
					ddd(1:2,kk) = bitsplit(frame32(kk),30,15);
				end
				kk = k(dnib == 3);		% dnib = 3 : three 10-bit differences
				if ~isempty(kk)
					ddd(1:3,kk) = bitsplit(frame32(kk),30,10);
				end
			end
			k = find(nibbles == 3);				% nibble = 3 : must look in dnib
			if ~isempty(k)
				dnib = bitshift(frame32(k),-30);
				kk = k(dnib == 0);		% dnib = 0 : five 6-bit difference
				if ~isempty(kk)
					ddd(1:5,kk) = bitsplit(frame32(kk),30,6);
				end
				kk = k(dnib == 1);		% dnib = 1 : six 5-bit differences
				if ~isempty(kk)
					ddd(1:6,kk) = bitsplit(frame32(kk),30,5);
				end
				kk = k(dnib == 2);		% dnib = 2 : seven 4-bit differences (28 bits!)
				if ~isempty(kk)
					ddd(1:7,kk) = bitsplit(frame32(kk),28,4);
				end
			end
			
		case 3	% *** STEIM-3 DECODING IS BETA AND UNTESTED ***
			% STEIM-3: 7 cases following the nibbles
			ddd = NaN*ones(9,numel(frame32));	% initiates array with NaN
			k = find(nibbles == 0);				% nibble = 0 : two 16-bit differences
			if ~isempty(k)
				ddd(1:2,k) = bitsplit(frame32(k),32,16);
			end
			k = find(nibbles == 1);				% nibble = 1 : four 8-bit differences
			if ~isempty(k)
				ddd(1:4,k) = bitsplit(frame32(k),32,8);
			end
			k = find(nibbles == 2);				% nibble = 2 : must look even dnib
			if ~isempty(k)
				dnib2 = bitshift(frame32(k(2:2:end)),-30);
				w60 = bitand(frame32(k(2:2:end)),bitcmp(0,2^30)) ...
					+ bitshift(bitand(frame32(k(1:2:end)),bitcmp(0,2^30)),30);	% concatenates two 30-bit words
				kk = find(dnib2 == 0);		% dnib = 0: five 12-bit differences (60 bits)
				if ~isempty(kk)
					ddd(1:5,k(2*kk)) = bitsplit(w60,60,12);
				end
				kk = find(dnib2 == 1);		% dnib = 1: three 20-bit differences (60 bits)
				if ~isempty(kk)
					ddd(1:3,k(2*kk)) = bitsplit(w60,60,20);
				end
			end
			k = find(nibbles == 3);				% nibble = 3 : must look 3rd bit
			if ~isempty(k)
				dnib = bitshift(frame32(k),-27);
				kk = k(dnib == 24);		% dnib = 11000 : nine 3-bit differences (27 bits)
				if ~isempty(kk)
					ddd(1:9,kk) = bitsplit(frame32(kk),27,3);
				end
				kk = k(dnib == 25);		% dnib = 11001 : Not A Difference
				if ~isempty(kk)
					ddd(1,kk) = bitsign(frame32(kk),27);
				end
				kk = k(dnib > 27);		% dnib = 111.. : 29-bit sample (29 bits)
				if ~isempty(kk)
					ddd(1,kk) = bitsign(frame32(kk),29);
				end
			end
		end
		
		dd = ddd(~isnan(ddd));		% dd is non-NaN values of ddd
		
		% rebuilds the data vector by integrating the differences
		D.d = cumsum([x0;dd(2:D.NumberSamples)]);
		
		% controls data integrity...
		if D.d(end) ~= xn
			warning('Problem in %s sequence number %s [%s] : reverse integration not respected.\n',char(D.EncodingFormatName),D.SequenceNumber,D.RecordStartTimeISO);
		end
		if numel(dd) ~= D.NumberSamples
			fprintf('Problem in %s sequence number %s [%s] : found extra data.\n',char(D.EncodingFormatName),D.SequenceNumber,D.RecordStartTimeISO);
		end

	case 12
		% --- decoding format: GEOSCOPE multiplexed 24-bit integer
		D.EncodingFormatName = 'GEOSCOPE24';
		dd = fread(fid,(D.DataRecordSize - D.OffsetBeginData)/3,'bit24=>double');
		if xor(~WordOrder,le)
			dd = swapbytes(dd);
		end
		D.d = dd(1:D.NumberSamples);
		
	case 13
		% --- decoding format: GEOSCOPE multiplexed 16/3-bit gain ranged
		%	bit 15 = unused
		%	bits 14-12 = 3-bit gain exponent (positive)
		%	bits 11-0 = 12-bit mantissa (positive)
		%	=> data = (mantissa - 2048) / 2^gain
		D.EncodingFormatName = 'GEOSCOPE16-3';
		dd = fread(fid,(D.DataRecordSize - D.OffsetBeginData)/2,'*uint16');
		if xor(~WordOrder,le)
			dd = swapbytes(dd);
		end
		dd = (double(bitand(dd,bitcmp(0,12)))-2^11)./2.^double(bitand(bitshift(dd,-12),bitcmp(0,3)));
		D.d = dd(1:D.NumberSamples);
		
	case 14
		% --- decoding format: GEOSCOPE multiplexed 16/4-bit gain ranged
		%	bits 15-12 = 4-bit gain exponent (positive)
		%	bits 11-0 = 12-bit mantissa (positive)
		%	=> data = (mantissa - 2048) / 2^gain
		D.EncodingFormatName = 'GEOSCOPE16-4';
		dd = fread(fid,(D.DataRecordSize - D.OffsetBeginData)/2,'*uint16');
		if xor(~WordOrder,le)
			dd = swapbytes(dd);
		end
		dd = (double(bitand(dd,bitcmp(0,12)))-2^11)./2.^double(bitand(bitshift(dd,-12),bitcmp(0,4)));
		D.d = dd(1:D.NumberSamples);
		
	case 15
		% --- decoding format: US National Network compression
		D.EncodingFormatName = 'USNN';
		uncoded = 1;
		
	case 16
		% --- decoding format: CDSN 16-bit gain ranged
		D.EncodingFormatName = 'CDSN';
		uncoded = 1;
		
	case 17
		% --- decoding format: Graefenberg 16-bit gain ranged
		D.EncodingFormatName = 'GRAEFENBERG';
		uncoded = 1;
		
	case 18
		% --- decoding format: IPG - Strasbourg 16-bit gain ranged
		D.EncodingFormatName = 'IPGS';
		uncoded = 1;
		
	case 30
		% --- decoding format: SRO format
		D.EncodingFormatName = 'SRO';
		uncoded = 1;
		
	case 31
		% --- decoding format: HGLP format
		D.EncodingFormatName = 'HGLP';
		uncoded = 1;
		
	case 32
		% --- decoding format: DWWSSN gain ranged format
		D.EncodingFormatName = 'DWWSSN';
		uncoded = 1;
		
	case 33
		% --- decoding format: RSTN 16-bit gain ranged
		D.EncodingFormatName = 'RSTN';
		uncoded = 1;
		
	otherwise
		D.EncodingFormatName = sprintf('** Unknown encoding format %d **',EncodingFormat);
		uncoded = 1;
		
end

if uncoded
	error('Sorry, the format "%s" is not yet implemented.',D.EncodingFormatName);
end

% makes the time vector
if EncodingFormat == 0
	D.t = D.RecordStartTimeMATLAB;
else
	D.t = D.RecordStartTimeMATLAB + (0:(D.NumberSamples-1))'/(D.SampleRate*86400);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = splitfield(s,d)
% splitfield(S) splits string S of D-character separated field names
r = s;
j = 1;
while (~isempty(r) & ischar(r))
	[t,r] = strtok(r,d);
	c{j} = t;
	j = j + 1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = readbtime(fid)
% readbtime(FID) reads BTIME structure from current file and returns
%	D = [YEAR,DAY,HOUR,MINUTE,SECONDS]
Year					= fread(fid,1,'uint16');
DayOfYear				= fread(fid,1,'uint16');
Hours					= fread(fid,1,'uint8');
Minutes					= fread(fid,1,'uint8');
Seconds					= fread(fid,1,'uint8=>double');
unused					= fread(fid,1,'uint8');
Seconds0001				= fread(fid,1,'uint16=>double');
d = [Year,DayOfYear,Hours,Minutes,Seconds + Seconds0001/1e4];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = bitsplit(x,b,n)
% bitsplit(X,B,N) splits the B-bit number X into signed N-bit array
%	X must be unsigned integer class
%	N ranges from 1 to B
%	B is a multiple of N

sign = repmat((b:-n:n)',1,size(x,1));
x = repmat(x',b/n,1);
d = double(bitand(bitshift(x,flipud(sign-b)),bitcmp(0,n))) ...
	- double(bitget(x,sign))*2^n;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = bitsign(x,n)
% bitsign(X,N) returns signed N-bit value from unsigned N-bit number X.
% This is equivalent to bitsplit(X,N,N), but the formula is simplified so
% it is much more efficient

d = double(bitand(x,bitcmp(0,n))) - double(bitget(x,n)).*2^n;
