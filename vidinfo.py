#!/usr/bin/env python2

import os,sys,subprocess,argparse,json,collections

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

def get_streams(url):
	command=['ffprobe','-v','quiet','-print_format','json','-show_streams','-show_format',str(url)]
	p=subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	output, err=p.communicate()
	return json.loads(output.decode('UTF-8'))

def get_quality(tpixels,vrate,arate,achannels):
	_score_pix = _score_vrate = _score_arate = _score_ach = _total_qual = 0
	_pix_max = 2073600
	_pix_min = 1
	_vbitrate_max = 6144
	_vbitrate_min = 200
	_abitrate_max = 1536
	_abitrate_min = 64
	_channels_max = 6
	_channels_min = 1
	_score_pix = ((float(tpixels) / (_pix_max -_pix_min)) * 100) * 0.4
	_score_vrate = ((float(vrate) / (_vbitrate_max - _vbitrate_min)) * 100) * 0.45
	_score_arate = ((float(arate) / (_abitrate_max - _abitrate_min)) * 100) * 0.4
	_score_ach = ((float(achannels) / (_channels_max - _channels_min)) * 100) * 0.08
	_total_qual = _score_pix + _score_vrate + _score_arate + _score_ach
	#print("pixels: {} | v-rate: {} | a-rate: {} | ch: {} | PScore: {} | VScore: {} | AScore: {} | CScore: {}".format(tpixels, vrate, arate, achannels, round(_score_pix,4), round(_score_vrate,4), round(_score_arate,4), round(_score_ach,4)) )
	return (_total_qual)

_ext_list = '.3gp','.asf','.avchd','.avi','.f4v','.flv','.m1v','.m2v','.m4v','.mkv','.mov','.mpg','.mpeg','.mpe','.mp4','.ogg','.rm','.ts','.webm','.wmv'

p = argparse.ArgumentParser(description="Provides video information for the given files")
p.add_argument('-f','--full',dest='full_info',default=0,action='store_true',help="Show full info for all streams")
p.add_argument('infile',nargs='*',default=None,help="Allows you to pass one or more filenames for information. If no filename is passed, all videos in the current folder will be inspected")

a=p.parse_args()

if len(a.infile) < 1:
	a.infile = sorted(os.listdir('.'))
	
for _file in a.infile:
	if _file.endswith(_ext_list):
		vidinfo = audinfo = subinfo = ''
		_vindex = _vcodec = _frame = _aspect = _vlang = ''
		_qbitrate = _qchannels = quality = 0
		_fps = _total_frames = _duration = _vbitrate = _format_bitrate = 0
		
		streams_full = get_streams(_file)
		streams_info = LowerDict(streams_full)
		
		_format_bitrate = round(int(streams_info['format']['bit_rate']) / 1000)
		_duration = float(streams_info['format']['duration'])
		
		for stream in streams_info['streams']:
			_acodec = _alang = _scodec = _slang = _vflags = _aflags = _sflags = ''
			_aindex = _abitrate = _achannels = _sindex = 0
			if stream['codec_type']=='video':
				_vindex = stream['index']
				_vcodec = stream['codec_name']
				_frame = ("{}x{}".format(stream['width'],stream['height']))
				_aspect = round((float(stream['width'])/stream['height']),3)
				_tpixels = int(stream['width'] * stream['height'])
				_fps_tmp = stream['r_frame_rate'].split('/')
				_fps = round(int(_fps_tmp[0]) / int(_fps_tmp[1]), 2)
				if stream['disposition']['default']==1:
					_vflags += '(D)'
				if stream['disposition']['forced']==1:
					_vflags += '(F)'
				if 'tags' in stream:
					if 'language' in stream['tags']:
						_vlang = stream['tags']['language']
				if 'bit_rate' in stream:
					_vbitrate = round(int(stream['bit_rate']) / 1000)
				else:
					_vbitrate = _format_bitrate
				if a.full_info:
					vidinfo+=("\nStream: {}	Codec: {}	Bitrate: {}kb/s	FPS: {} Frame Size: {}	Aspect: {}	Language: {}".format(_vindex,_vcodec,_vbitrate,_fps,_frame,_aspect,_vlang))
				else:
					vidinfo+=("{}:={} {}: {} ({}) {}fps, {}kb/s".format(_vindex,_vflags,_vcodec,_frame,_aspect,_fps,_vbitrate))
			elif stream['codec_type']=='audio':
				_aindex=stream['index']
				_acodec=stream['codec_name']
				if 'bit_rate' in stream:
					_abitrate=round(int(stream['bit_rate']) / 1000)
				_achannels=stream['channels']
				if int(_abitrate) > int(_qbitrate):
					_qbitrate=_abitrate
				if int(_achannels) > int(_qchannels):
					_qchannels=_achannels
				if stream['disposition']['default']==1:
					_aflags+='(D)'
				if stream['disposition']['forced']==1:
					_aflags+='(F)'
				if 'tags' in stream:
					if 'language' in stream['tags']:
						_alang=stream['tags']['language']
				if a.full_info:
					audinfo+=("\nStream: {}	Codec: {}	Bitrate: {}kb/s	Channels: {}	Language: {}".format(_aindex,_acodec,_abitrate,_achannels,_alang))
				else:
					audinfo+=(" {}:={} {}: {}kb/s {}ch ({})".format(_aindex,_aflags,_acodec,_abitrate,_achannels,_alang))
			elif stream['codec_type']=='subtitle':
				_sindex=stream['index']
				_scodec=stream['codec_name']
				if stream['disposition']['default']==1:
					_sflags+='(D)'
				if stream['disposition']['forced']==1:
					_sflags+='(F)'
				if 'tags' in stream:
					if 'language' in stream['tags']:
						_slang=stream['tags']['language']
				if a.full_info:
					subinfo+=("\nStream: {}	Codec: {}	Language: {}".format(_sindex,_scodec,_slang))
				else:
					subinfo+=(" {}:={} {} ({})".format(_sindex,_sflags,_scodec,_slang))
		_total_frames=int(_duration * _fps)
		
		quality=round(get_quality(_tpixels,_vbitrate,_qbitrate,_qchannels), 2)
		if a.full_info:
			print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
			print("A/V Information for {}:".format(_file))
			print("+++++ Video Streams +++++{}".format(vidinfo))
			print("+++++ Audio Streams +++++{}".format(audinfo))
			print("++++ Subtitle Streams +++{}".format(subinfo))
			print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
		else:
			print("++|| {} || {}kb/s overall || {} ||++".format(quality,_format_bitrate,_file))
			print("++|| {} || {} || {} ||++".format(vidinfo,audinfo,subinfo))
			print("")
