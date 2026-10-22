import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
class PlayerProgress {
 const PlayerProgress({this.solved=const {},this.score=0});
 final Map<String,int> solved; final int score;
 int get solvedCount=>solved.length; int get totalStars=>solved.values.fold(0,(a,b)=>a+b);
 PlayerProgress solve(String id,int stars,int points)=>solved.containsKey(id)?this:PlayerProgress(solved:{...solved,id:stars},score:score+points);
 Map<String,dynamic> toJson()=>{'solved':solved,'score':score};
 factory PlayerProgress.fromJson(Map<String,dynamic> json){final solved=<String,int>{}; final raw=json['solved']; if(raw is Map){for(final e in raw.entries){if(e.key is String&&e.value is num)solved[e.key as String]=(e.value as num).toInt().clamp(0,3).toInt();}} return PlayerProgress(solved:solved,score:(json['score'] as num?)?.toInt()??0);}
}
class ProgressStore {
 static const _key='zihinlab.progress.v1';
 Future<PlayerProgress> load() async {final prefs=await SharedPreferences.getInstance();final raw=prefs.getString(_key);if(raw==null)return const PlayerProgress();try{return PlayerProgress.fromJson(jsonDecode(raw) as Map<String,dynamic>);}catch(_){return const PlayerProgress();}}
 Future<void> save(PlayerProgress p) async {final prefs=await SharedPreferences.getInstance();await prefs.setString(_key,jsonEncode(p.toJson()));}
}
