require "test_helper"

#
# À DUPLIQUER
# 

class RelativePFAValidityTests < Minitest::Test

  def setup
    super
    @pfa = nil
  end
  def teardown
  end

  def pfa ; @pfa ||= PFA::RelativePFA.new() end

  def test_valid_if_all_data_required
    # La méthode valid? retourne true si toutes les données requises
    # ont été fournies
    {
      zero:                 '0,0,30', 
      end_time:             '2,0,0',
      incident_declencheur: {t:'0,10,0',  d:"L'incident déclencheur"},
      pivot1:               {t:'0,25,0',  d:"Le pivot 1"},
      developpement_part1:  {t:'0,31,0',  d:"Début du développement"},
      cle_de_voute:         {t:'0,60,0',  d:"La clé de voûte du film"},
      developpement_part2:  {t:'0,70,0',  d:"La deuxième partie du développement"},
      pivot2:               {t:'0,80,0',  d:"Le pivot 2"},
      denouement:           {t:'0,90,0',  d:"C'est le début du dénouement"},
      climax:               {t:'0,100,0', d:"Le climax", duree: 120},
    }.each do |key, value|
      pfa.add(key, value)
    end
    assert_silent { pfa.valid? }
  end

  def test_not_valid_if_not_zero
    @pfa = nil
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    assert_equal(PFA::ERRORS[200], err.message)
  end

  def test_not_valid_if_not_end_time
    @pfa = nil
    pfa.add :zero, '0+0+20'
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    assert_equal(PFA::ERRORS[201], err.message)
  end

  def test_not_valid_if_not_incident_declencheur
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    assert_equal(PFA::ERRORS[202], err.message)
  end

  def test_not_valid_if_not_pivot1
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, '0,10,0'
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    assert_equal(PFA::ERRORS[203], err.message)
  end

  def test_not_valid_if_not_developpement_part1
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, {t:'0,10,0', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,20,0', d:'Ce pivot', duree: 136}
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    assert_equal(PFA::ERRORS[204], err.message)
  end

  def test_not_valid_if_not_pivot2
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, {t:'0,10,0', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,20,0', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '0,30,0', d:'Ce Dev part 1'}
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    assert_equal(PFA::ERRORS[205], err.message)
  end

  def test_not_valid_if_not_denouement
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, {t:'0,10,0', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,20,0', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '0,30,0', d:'Ce Dev part 1'}
    pfa.add :pivot2, {t: '0,80,0', d:'Ce pivot', duree: 11*60}
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    assert_equal(PFA::ERRORS[206], err.message)
  end

  def test_not_valid_if_not_climax
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, {t:'0,10,0', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,20,0', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '0,30,0', d:'Ce Dev part 1'}
    pfa.add :pivot2, {t: '0,80,0', d:'Ce pivot', duree: 11*60}
    pfa.add :denouement, {t: '0,90,0', d:'Ce dénouement'}
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    assert_equal(PFA::ERRORS[207], err.message)
  end

  def test_not_valid_if_not_incident_declencheur_after_zero
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, {t:'0,0,15', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,20,0', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '0,30,0', d:'Ce Dev part 1'}
    pfa.add :pivot2, {t: '0,80,0', d:'Ce pivot', duree: 11*60}
    pfa.add :denouement, {t: '0,90,0', d:'Ce dénouement'}
    pfa.add :climax, {t: '0,110,0', d:'Ce climax'}
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    data = {
      key_before: 'zero',               h_before:'0:00:20', 
      key_after:'incident_declencheur', h_after:'0:00:15'
    }
    assert_equal(PFA::ERRORS[220] % data, err.message)
  end

  def test_not_valid_if_not_incident_declencheur_before_pivot1
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, {t:'0,10,0', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,9,0', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '0,30,0', d:'Ce Dev part 1'}
    pfa.add :pivot2, {t: '0,80,0', d:'Ce pivot', duree: 11*60}
    pfa.add :denouement, {t: '0,90,0', d:'Ce dénouement'}
    pfa.add :climax, {t: '0,110,0', d:'Ce climax'}
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    data = {
      key_before: 'incident_declencheur',               h_before:'0:10:00', 
      key_after:'pivot1', h_after:'0:09:00'
    }
    assert_equal(PFA::ERRORS[220] % data, err.message)
  end

  def test_not_valid_if_not_developpement_part1_after_pivot1
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, {t:'0,10,0', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,15,0', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '0,12,0', d:'Ce Dev part 1'}
    pfa.add :pivot2, {t: '0,80,0', d:'Ce pivot', duree: 11*60}
    pfa.add :denouement, {t: '0,90,0', d:'Ce dénouement'}
    pfa.add :climax, {t: '0,110,0', d:'Ce climax'}
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    data = {
      key_before: 'pivot1',            h_before:'0:15:00', 
      key_after:'developpement_part1', h_after:'0:12:00'
    }
    assert_equal(PFA::ERRORS[220] % data, err.message)
  end

  def test_not_valid_if_not_cle_de_voute_after_developpement_part1
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, {t:'0,10,0', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,15,0', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '0,30,0', d:'Ce Dev part 1'}
    pfa.add :cle_de_voute, {t: '0,20,0', d:'Cette clé de voute', duree: 11*60}
    pfa.add :pivot2, {t: '0,80,0', d:'Ce pivot', duree: 11*60}
    pfa.add :denouement, {t: '0,90,0', d:'Ce dénouement'}
    pfa.add :climax, {t: '0,110,0', d:'Ce climax'}
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    data = {
      key_before: 'developpement_part1',            h_before:'0:30:00', 
      key_after:'cle_de_voute', h_after:'0:20:00'
    }
    assert_equal(PFA::ERRORS[220] % data, err.message)
  end

  def test_not_valid_if_not_developpement_part2_after_cle_de_voute
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, {t:'0,10,0', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,15,0', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '0,30,0', d:'Ce Dev part 1'}
    pfa.add :cle_de_voute, {t: '0,60,0', d:'Cette clé de voute', duree: 11*60}
    pfa.add :developpement_part2, {t: '0,55,0', d:'Ce Dev part II'}
    pfa.add :pivot2, {t: '0,80,0', d:'Ce pivot', duree: 11*60}
    pfa.add :denouement, {t: '0,90,0', d:'Ce dénouement'}
    pfa.add :climax, {t: '0,110,0', d:'Ce climax'}
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    data = {
      key_before: 'cle_de_voute',            h_before:'1:00:00', 
      key_after:'developpement_part2', h_after:'0:55:00'
    }
    assert_equal(PFA::ERRORS[220] % data, err.message)
  end

  def test_not_valid_if_not_pivot2_after_developpement_part2
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, {t:'0,10,0', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,15,0', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '0,30,0', d:'Ce Dev part 1'}
    pfa.add :cle_de_voute, {t: '0,60,0', d:'Cette clé de voute', duree: 11*60}
    pfa.add :developpement_part2, {t: '0,70,0', d:'Ce Dev part II'}
    pfa.add :pivot2, {t: '0,60,0', d:'Ce pivot', duree: 11*60}
    pfa.add :denouement, {t: '0,90,0', d:'Ce dénouement'}
    pfa.add :climax, {t: '0,110,0', d:'Ce climax'}
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    data = {
      key_before: 'developpement_part2',            h_before:'1:10:00', 
      key_after:'pivot2', h_after:'1:00:00'
    }
    assert_equal(PFA::ERRORS[220] % data, err.message)
  end
  def test_not_valid_if_not_pivot2_after_pivot1
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, {t:'0,10,0', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,15,0', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '0,30,0', d:'Ce Dev part 1'}
    pfa.add :cle_de_voute, {t: '0,60,0', d:'Cette clé de voute', duree: 11*60}
    pfa.add :developpement_part2, {t: '0,70,0', d:'Ce Dev part II'}
    pfa.add :pivot2, {t: '0,10,0', d:'Ce pivot', duree: 11*60}
    pfa.add :denouement, {t: '0,90,0', d:'Ce dénouement'}
    pfa.add :climax, {t: '0,110,0', d:'Ce climax'}
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    data = {
      key_before: 'pivot1',            h_before:'0:15:00', 
      key_after:'pivot2', h_after:'0:10:00'
    }
    assert_equal(PFA::ERRORS[220] % data, err.message)
  end

  def test_not_valid_if_not_denouement_after_pivot2
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, {t:'0,10,0', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,15,0', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '0,30,0', d:'Ce Dev part 1'}
    pfa.add :cle_de_voute, {t: '0,60,0', d:'Cette clé de voute', duree: 11*60}
    pfa.add :developpement_part2, {t: '0,70,0', d:'Ce Dev part II'}
    pfa.add :pivot2, {t: '0,80,0', d:'Ce pivot', duree: 11*60}
    pfa.add :denouement, {t: '0,70,0', d:'Ce dénouement'}
    pfa.add :climax, {t: '0,110,0', d:'Ce climax'}
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    data = {
      key_before: 'pivot2',            h_before:'1:20:00', 
      key_after:'denouement', h_after:'1:10:00'
    }
    assert_equal(PFA::ERRORS[220] % data, err.message)
  end

  def test_not_valid_if_not_climax_after_denouement
    @pfa = nil
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, {t:'0,10,0', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,15,0', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '0,30,0', d:'Ce Dev part 1'}
    pfa.add :cle_de_voute, {t: '0,60,0', d:'Cette clé de voute', duree: 11*60}
    pfa.add :developpement_part2, {t: '0,70,0', d:'Ce Dev part II'}
    pfa.add :pivot2, {t: '0,80,0', d:'Ce pivot', duree: 11*60}
    pfa.add :denouement, {t: '0,90,0', d:'Ce dénouement'}
    pfa.add :climax, {t: '0,85,0', d:'Ce climax'}
    err = assert_raises(PFA::PFAFatalError) { pfa.valid? }
    data = {
      key_before: 'denouement',            h_before:'1:30:00', 
      key_after:'climax', h_after:'1:25:00'
    }
    assert_equal(PFA::ERRORS[220] % data, err.message)
  end

end #/Minitest::Test
