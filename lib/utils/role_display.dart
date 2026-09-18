/// Formats a role code ("IE_ANALYST") into a display name ("IE Analyst") - shared
/// so every screen that shows a role name treats acronyms the same way instead of
/// each re-implementing its own word-by-word title-case (which reads "Ie Analyst").
class RoleDisplay {
  const RoleDisplay._();

  static const _acronyms = {'IE', 'QC', 'HR'};

  static String name(String roleCode) {
    return roleCode.split('_').map((word) {
      if (word.isEmpty) return '';
      if (_acronyms.contains(word.toUpperCase())) return word.toUpperCase();
      return word[0] + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
