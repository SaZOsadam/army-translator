class BTSDictionary {
  // BTS-specific terms that should be kept or translated specially
  static const Map<String, String> terms = {
    // Fandom terms
    '아미': 'ARMY',
    '아미들': 'ARMYs',
    '보라해': 'I purple you 💜',
    '보라해요': 'I purple you 💜',
    
    // Member names (Korean -> Stage name)
    '남준': 'Namjoon',
    '남준이': 'Namjoon',
    '김남준': 'RM',
    '석진': 'Jin',
    '석진이': 'Jin',
    '김석진': 'Jin',
    '윤기': 'Yoongi',
    '윤기야': 'Yoongi',
    '민윤기': 'SUGA',
    '호석': 'Hoseok',
    '호석이': 'Hoseok',
    '정호석': 'J-Hope',
    '지민': 'Jimin',
    '지민이': 'Jimin',
    '박지민': 'Jimin',
    '태형': 'Taehyung',
    '태형이': 'Taehyung',
    '김태형': 'V',
    '정국': 'Jungkook',
    '정국이': 'Jungkook',
    '전정국': 'Jungkook',
    
    // Nicknames
    '랩몬': 'Rap Mon',
    '슈가': 'SUGA',
    '제이홉': 'J-Hope',
    '뷔': 'V',
    
    // Korean honorifics (keep as-is)
    '형': 'hyung',
    '형아': 'hyung',
    '오빠': 'oppa',
    '누나': 'noona',
    '언니': 'unnie',
    '동생': 'dongsaeng',
    
    // Family terms
    '막내': 'maknae',
    '막내라인': 'maknae line',
    '형라인': 'hyung line',
    
    // BTS-specific
    '방탄소년단': 'BTS',
    '방탄': 'Bangtan',
    '탄이들': 'Tannies',
    '빅히트': 'BigHit',
    '하이브': 'HYBE',
    '위버스': 'Weverse',
    '브이라이브': 'V Live',
    
    // Albums & Songs
    '아리랑': 'ARIRANG',
    '버터': 'Butter',
    '다이너마이트': 'Dynamite',
    '퍼미션투댄스': 'Permission to Dance',
    '마이유니버스': 'My Universe',
    
    // Concert/Tour terms
    '월드투어': 'world tour',
    '콘서트': 'concert',
    '팬미팅': 'fan meeting',
    '무대': 'stage',
    '앵콜': 'encore',
    '떼창': 'fan chant',
    
    // Common expressions
    '사랑해': 'I love you',
    '사랑해요': 'I love you',
    '고마워': 'thank you',
    '고마워요': 'thank you',
    '보고싶어': 'I miss you',
    '보고싶어요': 'I miss you',
    '잘 자': 'good night',
    '잘 자요': 'good night',
    '안녕': 'hi/bye',
    '안녕하세요': 'hello',
    
    // Weverse/Live specific
    '라이브': 'live',
    '채팅': 'chat',
    '댓글': 'comment',
    '좋아요': 'like',
    '구독': 'subscribe',
  };
  
  // Phrases that need context-aware translation
  static const Map<String, String> contextPhrases = {
    '아 진짜': 'ah really / oh come on',
    '대박': 'amazing / wow',
    '헐': 'oh my god / what',
    '아이고': 'oh my / aigoo',
    '화이팅': 'fighting! (you can do it)',
    '파이팅': 'fighting! (you can do it)',
    '멋있어': "that's cool / you're cool",
    '귀여워': "that's cute / you're cute",
    '예뻐': "that's pretty / you're pretty",
    '잘생겼어': "you're handsome",
  };
  
  // Apply BTS dictionary to translated text
  static String applyDictionary(String koreanText) {
    String result = koreanText;
    
    // Apply term replacements
    terms.forEach((korean, english) {
      result = result.replaceAll(korean, english);
    });
    
    return result;
  }
  
  // Get member name from Korean
  static String? getMemberName(String koreanName) {
    final memberMappings = {
      '남준': 'RM',
      '석진': 'Jin',
      '윤기': 'SUGA',
      '호석': 'J-Hope',
      '지민': 'Jimin',
      '태형': 'V',
      '정국': 'Jungkook',
    };
    
    for (final entry in memberMappings.entries) {
      if (koreanName.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }
  
  // Detect if text mentions a specific member
  static List<String> detectMentionedMembers(String text) {
    final mentioned = <String>[];
    
    final memberKeywords = {
      'RM': ['남준', 'RM', '랩몬', '김남준'],
      'Jin': ['석진', 'Jin', '진', '김석진'],
      'SUGA': ['윤기', 'SUGA', '슈가', '민윤기'],
      'J-Hope': ['호석', 'J-Hope', '제이홉', '정호석'],
      'Jimin': ['지민', 'Jimin', '박지민'],
      'V': ['태형', 'V', '뷔', '김태형'],
      'Jungkook': ['정국', 'Jungkook', '전정국'],
    };
    
    memberKeywords.forEach((member, keywords) {
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          if (!mentioned.contains(member)) {
            mentioned.add(member);
          }
          break;
        }
      }
    });
    
    return mentioned;
  }
}
