#!/usr/bin/env python2

print('=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+')
print(' _______  _______  _______  _______  _______  _______    _______  _______  _                 _______  _______  _______ _________ _______  _       ')
print('(  ____ \(  ____ \(       )(  ____ )(  ____ \(  ____ \  (  ____ \(  ___  )( (    /||\     /|(  ____ \(  ____ )(  ____ \\__   __/(  ___  )( (    /|')
print('| (    \/| (    \/| () () || (    )|| (    \/| (    \/  | (    \/| (   ) ||  \  ( || )   ( || (    \/| (    )|| (    \/   ) (   | (   ) ||  \  ( |')
print('| (__    | (__    | || || || (____)|| (__    | |        | |      | |   | ||   \ | || |   | || (__    | (____)|| (_____    | |   | |   | ||   \ | |')
print('|  __)   |  __)   | |(_)| ||  _____)|  __)   | | ____   | |      | |   | || (\ \) |( (   ) )|  __)   |     __)(_____  )   | |   | |   | || (\ \) |')
print('| (      | (      | |   | || (      | (      | | \_  )  | |      | |   | || | \   | \ \_/ / | (      | (\ (         ) |   | |   | |   | || | \   |')
print('| )      | )      | )   ( || )      | (____/\| (___) |  | (____/\| (___) || )  \  |  \   /  | (____/\| ) \ \__/\____) |___) (___| (___) || )  \  |')
print('|/       |/       |/     \||/       (_______/(_______)  (_______/(_______)|/    )_)   \_/   (_______/|/   \__/\_______)\_______/(_______)|/    )_)')
print('=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+')

import os,sys,subprocess,signal,shutil,argparse,json,select,pexpect,collections
from progressbar import Bar,ETA,Percentage,ProgressBar

class LowerDict(collections.Mapping):
	def __init__(self, d):
		self._d = d
		self._s = dict((k.lower(), k) for k in d)
	def __contains__(self, k):
		return k.lower() in self._s
	def __len__(self):
		return len(self._s)
	def __iter__(self):
		return iter(self._s)
	def __getitem__(self, k):
		return self._d[self._s[k.lower()]]
	def actual_key_case(self, k):
		return self._s.get(k.lower())

def signal_handler(signal, frame):
	print('\nEMERGENCY EXIT!!! ALL JOBS QUITTING!!!\n')
	sys.exit(0)

def get_streams(url):
	command=['ffprobe','-v','quiet','-print_format','json','-show_streams','-show_format',str(url)]
	p=subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	output, err=p.communicate()
	return json.loads(output.decode('UTF-8'))

class FFsettings(object):
	# basic class values
	outdir = './converted/'
	donedir = './originals/'
	logdir = './ffmpeg_logs/'
	preset_low = 'medium'
	preset_med = 'slow'
	preset_high = 'slow'
	preset_ultra = 'slower'
	rate_low = '700k'
	rate_med = '1M'
	rate_high = '2M'
	rate_ultra = '4M'
	vtype = 'normal'
	maxres = None
	lowqual = force_aac = force_subs = 0
	vmap = amap = smap = oscale = scale = rate = vpreset = audio_opts = ''
	acodec = 'copy'
	abitrate = None
	achannels = achannelsorig = 0
	alang = None
	aindex = None
	outext = '.mp4'
	sub_opts = '-sn'
	sublang = None
	allowed_codecs = 'ac3','aac','dca' # ac3, dca: 5.1 and DTS  aac is target codec for all else
	def __init__(self,args):
		# set basics based on args
		if args.vtype is not None:
			if args.vtype=='cartoon' or args.vtype=='anime':
				self.rate_low = '500k'
				self.rate_med = '750k'
				self.rate_high = '1500k'
				self.rate_ultra = '2500k'
				self.vtype = args.vtype
		if args.preset is not None:
			self.preset_low = self.preset_med = self.preset_high = args.preset
		if args.maxres is not None:
			self.maxres = args.maxres
		if args.acodec==1:
			self.force_aac = 1
		if args.subtitles==1:
			self.force_subs = 1
		if args.lowqual==1:
			self.lowqual = 1
		if len(args.infile)>1 and not args.test:
			if not os.path.exists(self.outdir):
				os.makedirs(self.outdir)
			if not os.path.exists(self.donedir):
				os.makedirs(self.donedir)
		elif len(a.infile)==1:
			self.donedir = None
		if not os.path.exists(self.logdir) and not args.test:
			os.makedirs(self.logdir)
	def _set_scale(self,width,height,target):
		_aspect = (float(width) / height)
		_new = int(round(target / _aspect))
		if (_new % 2 != 0):
			_new -= 1
		self.scale = (" -vf scale={}:{}".format(target, _new))
	def map(self):
		# return mapping string for ffmpeg command
		return "{}{}{}".format(self.vmap, self.amap, self.smap)
	def clear_opts(self):
		# clear values that get set in the respective video, audio, and subtitles functions (for looping)
		self.vmap = self.amap = self.smap = self.oscale = self.scale = self.rate = self.vpreset = self.audio_opts = ''
		self.acodec = 'copy'
		self.abitrate = None
		self.achannels = 0
		self.alang = None
		self.aindex = None
		self.outext = '.mp4'
		self.subopts = '-sn'
		self.sublang = None
	def set_vidopts(self,sinfo):
		# set video option values based on original video data and args
		self.vmap = ("-map 0:{}".format(sinfo['index']))
		self.oscale = ("{}x{}".format(sinfo['width'], sinfo['height']))
		if self.lowqual:
			self.rate = "500k"
			self.vpreset = "faster"
			if int(sinfo['width']) > 800:
				self._set_scale(sinfo['width'], sinfo['height'], 800)
		elif int(sinfo['width']) < 800 or self.maxres=='low':
			self.rate = self.rate_low
			self.vpreset = self.preset_low
		elif (int(sinfo['width']) >= 800 and int(sinfo['width']) < 1280) or self.maxres=='medium':
			self.rate = self.rate_med
			self.vpreset = self.preset_med
			if int(sinfo['width']) > 800:
				self._set_scale(sinfo['width'], sinfo['height'],800)
		elif (int(sinfo['width']) >= 1280 and int(sinfo['width']) < 1920) or self.maxres=='high':
			self.rate = self.rate_high
			self.vpreset = self.preset_high
			if int(sinfo['width']) > 1280:
				self._set_scale(sinfo['width'], sinfo['height'],1280)
		elif int(sinfo['width']) >= 1920 or self.maxres=='ultra':
			self.rate = self.rate_ultra
			self.vpreset = self.preset_ultra
			if int(sinfo['width']) > 1920:
				self._set_scale(sinfo['width'], sinfo['height'],1920)
	def set_audio_opts(self,sinfo):
		# set audio option values based on original audio data and args
		if 'tags' in sinfo:
			if 'language' in sinfo['tags']:
				self.alang = sinfo['tags']['language']
		if self.vtype=='anime' and self.alang=='jpn':
			self.aindex = sinfo['index']
		elif a.vtype!='anime' and self.alang=='eng':
			self.aindex = sinfo['index']
		elif a.vtype!='anime' and (self.alang==None or self.alang=='und'):
			self.aindex = sinfo['index']
		if self.aindex is not None:
			self.amap = (" -map 0:{}".format(self.aindex))
			self.achannels = self.achannelsorig = int(sinfo['channels'])
			if sinfo['codec_name'] not in self.allowed_codecs or self.force_aac==1:
				self.acodec = 'libfdk_aac'
				self.abitrate = '192k'
			if self.maxres=='low':
				self.acodec = 'libfdk_aac'
				self.abitrate = '128k'
			if self.lowqual==1:
				self.acodec = 'libfdk_aac'
				self.abitrate = '96k'
			if self.acodec!='copy':
				self.achannels = 2
			self.audio_opts = ("-c:a {}".format(self.acodec))
			if self.abitrate is not None:
				self.audio_opts += (" -ab {}".format(self.abitrate))
	def set_subopts(self,sinfo):
		# set subtitle option values based on original subtitle data and args
		_sindex = None
		if 'tags' in sinfo:
			if 'language' in sinfo['tags']:
				self.sublang = sinfo['tags']['language']
			if self.sublang is not None and 'title' in sinfo['tags']:
				if sinfo['tags']['title']=='forced':
					_sindex = sinfo['index']
		if int(sinfo['disposition']['forced'])==1:
			_sindex = sinfo['index']
		if self.vtype=='anime' and self.sublang=='eng':
			_sindex = sinfo['index']
		elif self.vtype=='anime' and int(sinfo['disposition']['default'])==1:
			_sindex = sinfo['index']
		if self.force_subs==1:
			_sindex = sinfo['index']
		if _sindex is not None:
			self.smap += (" -map 0:{}".format(_sindex))
			self.sub_opts = '-c:s copy'
	def choose_container(self):
		# choose the output container; mp4 does not support 5.1/DTS or attached subtitles
		if (self.achannels > 2 and self.acodec=='copy') or len(self.smap) > 0:
			self.outext='.mkv'
	def make_ffopts(self,ffpass=None):
		# assemble and return ffmpeg options based on ffpass arg
		if ffpass==1:
			_ffopts = ("-c:v libx264 -b:v {}{} -preset {} -an -sn -pass 1".format(self.rate, self.scale, self.vpreset))
		elif ffpass==2:
			_ffopts = ("{} -c:v libx264 -b:v {}{} -preset {} {} {} -pass 2".format(self.map(), self.rate, self.scale, self.vpreset, self.audio_opts, self.sub_opts))
		elif ffpass is None:
			if a.vcopy:
				_ffopts = ("{} -c:v copy {} {}".format(self.map(), self.audio_opts, self.sub_opts))
			else:
				_ffopts = ("{} -c:v libx264 -b:v {}{} -preset {} {} {}".format(self.map(), self.rate, self.scale, self.vpreset, self.audio_opts, self.sub_opts))
		return _ffopts

def get_duration(url):
	_hours=_mins=_secs=_frames=_fps=_total=_bitrate=0
	_cmd=('ffprobe -v quiet -show_format -select_streams v -show_streams "{}"'.format(url))
	_thread=pexpect.spawn(_cmd)
	_patterns=['duration=(\d+).','bit_rate=(\d+)','r_frame_rate=(\d+)/(\d+)',pexpect.EOF]
	_cpl=_thread.compile_pattern_list(_patterns)
	while True:
		i=_thread.expect_list(_cpl,timeout=None)
		if i==0:
			_secs=int(_thread.match.group(1))
		elif i==1:
			_bitrate=int(_thread.match.group(1))/1000
		elif i==2:
			_fps=float(format(float(_thread.match.group(1))/float(_thread.match.group(2)), '.2f'))
		elif i==3:
			break
		_total = int(round(int(_secs)*float(_fps)))
	return (_fps,_total,_bitrate)

def encode(infile,outfile,opts,threads,logdir):
	# pass options to ffmpeg for processing with progressbar and ETA
	(fps,total,bitrate) = get_duration(infile)
	cmd = ('ffmpeg -y -threads {} -i "{}" {} "{}"'.format(threads, infile, opts, outfile))
	print_cmd = ('ffmpeg -i "{}" {}'.format(infile, opts))
	print("{}".format(print_cmd))
	signal.signal(signal.SIGINT, signal_handler)
	print 'Press Ctrl-C to stop'
	logpath = ("{}{}.ffmpeg.log".format(logdir, infile))
	logfile = open(logpath,'w')
	thread = pexpect.spawn(cmd)
	thread.logfile = logfile
	patterns = [pexpect.EOF, "frame= *(\d+)"]
	cpl=thread.compile_pattern_list(patterns)
	_widgets = [Bar(), '>>> ', Percentage(), ' ', ETA()]
	pbar = ProgressBar(widgets = _widgets, maxval=102)
	pbar.start()
	while True:
		i = thread.expect_list(cpl,timeout=None)
		if i == 0: # EOF
			pbar.finish()
			logfile.close()
			break
		elif i == 1:
			curframe = int(thread.match.group(1))
			percent = round((float(curframe) / float(total) * 100),2)
			#print(percent)
			pbar.update(percent)
			thread.close

# TODO Look into a better video detection method than just file extension
_ext_list = '.3gp','.asf','.avchd','.avi','.f4v','.flv','.m1v','.m2v','.m4v','.mkv','.mov','.mpg','.mpeg','.mpe','.mp4','.ogg','.rm','.ts','.webm','.wmv'
_presets = ['ultrafast','superfast','veryfast','faster','fast','medium','slow','slower','veryslow','placebo']
_res = ['low','medium','high','ultra']
_vtypes = ['normal','cartoon','anime']

p=argparse.ArgumentParser(description="Converts video files to x264 (and aac audio when needed) using standard parameters")
p.add_argument('-t','--test',dest='test',default=0,action='store_true',help="Test mode. Displays the ffmpeg command(s) that would be used and exits")
p.add_argument('-aac',dest='acodec',default=0,action='store_true',help="Allows you to specify aac as the audio codec (not typically necessary)")
p.add_argument('-p',dest='preset',choices=_presets,default=None,help="Specifies the x264 preset to use for encoding; overriden by the Low-quality flag (-x/--lowqual)")
p.add_argument('-s','--subtitles',dest='subtitles',default=0,action='store_true',help="Preserves subtitles (default action is no subtitles, unless forced tag is marked)")
p.add_argument('-r','--maxres',dest='maxres',choices=_res,default=None,help="Sets the maximum resolution for conversion")
p.add_argument('-v','--videotype',dest='vtype',choices=_vtypes,default=None,help="Specifies the type of video to be processed; Cartoons are lower bitrate, Anime enables subtitles and selects japanese audio, default: Normal")
p.add_argument('-x','--lowqual',dest='lowqual',default=0,action='store_true',help="Low-quality flag. Sets (and overrides) the following options: bitrate=500k preset=veryfast acodec=aac abitrate=96k (2ch)")
p.add_argument('-vcopy',dest='vcopy',default=0,action='store_true',help="Will override the video codec and bitrate settings to copy the original video stream (no video transcoding)")
p.add_argument('--threads',dest='threads',type=int,default=5,help="How many threads to use for the ffmpeg process; default: 5")
p.add_argument('infile',nargs='*',default=None,help="Allows you to pass one or more filenames for conversion. If no filename is passed, all videos in the current folder will be converted")
a = p.parse_args()

if len(a.infile)==0:
	a.infile = sorted(os.listdir('.'))

s = FFsettings(a)

single = multi = 0
if len(a.infile)==1:
	single = 1
elif len(a.infile)>1:
	multi = 1

for _file in a.infile:
	if _file.endswith(_ext_list):
		if multi:
			s.clear_opts()
		streams_full = get_streams(_file)
		streams_info = LowerDict(streams_full)
		for stream in streams_info['streams']:
			if stream['codec_type']=='video':
				s.set_vidopts(stream)
			elif stream['codec_type']=='audio':
				s.set_audio_opts(stream)
			elif stream['codec_type']=='subtitle':
				s.set_subopts(stream)
		s.choose_container()
		orig_vbitrate = round(int(streams_info['format']['bit_rate']) / 1000)
		fname,fext = os.path.splitext(_file)
		if single:
			if fext==s.outext:
				fname += '_sized'
			OUTFILE = fname + s.outext
		elif multi:
			OUTFILE = s.outdir + fname + s.outext
		print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
		print("{} is being processed with the following options:\n\nvideo: libx264	bitrate: {}	scale:{}	preset: {}".format(_file,s.rate,s.scale,s.vpreset))
		print("audio: {}	bitrate: {}	language: {}\nsubtitles: {}		language: {}\n\nOutput file: {}\n\nORIGINAL FILE VALUES: Audio Channels: {}	 Frame Size: {}	Video Bitrate: {}kb/s".format(s.acodec,s.abitrate,s.alang,s.sub_opts,s.sublang,OUTFILE,s.achannelsorig,s.oscale,orig_vbitrate))
		#print(get_duration(_file))
		print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
		if a.test:
			print("\n!!!!! TEST MODE ENABLED !!!!!     What would have been done:\n")
			print("PASS 1:  ffmpeg -y -threads {} -i '{}' {} {}".format(a.threads,_file,s.make_ffopts(1),OUTFILE))
			print("PASS 2:  ffmpeg -y -threads {} -i '{}' {} {}".format(a.threads,_file,s.make_ffopts(2),OUTFILE))
			print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
		else:
			if a.vcopy:
				encode(_file,OUTFILE,s.make_ffopts(),a.threads,s.logdir)
			else:
				encode(_file,OUTFILE,s.make_ffopts(1),a.threads,s.logdir)
				encode(_file,OUTFILE,s.make_ffopts(2),a.threads,s.logdir)
			if multi:
				print("Now moving {} to originals...".format(_file))
				shutil.move(_file,s.donedir)
				print("Done")
